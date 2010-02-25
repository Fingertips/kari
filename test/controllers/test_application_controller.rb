require File.expand_path('../../test_helper', __FILE__)

class ApplicationController
  # Directly apply the frame instead of animating, so we can use assert_difference.
  def animate(views)
    views.each { |view, frame| view.frame = frame }
  end
end

module ApplicationControllerSpecHelper
  include FixtureHelpers
  
  def after_setup
    ib_outlets :webViewController => WebViewController.alloc.init,
               :webView => OSX::WebView.alloc.init,
               :resultsScrollView => OSX::NSScrollView.alloc.init,
               :searchTextField => OSX::NSSearchField.alloc.init
    
    webViewController.instance_variable_set(:@webview, webView)
    webViewController.stubs(:load_file)
    
    searchTextField.stringValue = 'ActiveRecord'
    
    @manager_mock = mock('Manager')
    @manager_mock.stubs(:namespace).returns([])
    @manager_mock.stubs(:examine)
    Manager.stubs(:instance).returns(@manager_mock)
    Manager.stubs(:bootstrap)
    Manager.stubs(:cleanup)
    Manager.stubs(:first_run?).returns(false)
    
    @watcher_mock = mock('Watcher')
    @watcher_mock.stubs(:delegate=)
    @watcher_mock.stubs(:start)
    @watcher_mock.stubs(:init).returns(@watcher_mock)
    Watcher.stubs(:alloc).returns(@watcher_mock)
    
    @namespace_mock = stub('Manager#namespace')
    @namespace_mock.stubs(:tree).returns({})
    @manager_mock.stubs(:namespace).returns(@namespace_mock)
    
    OSX::NSTimer.stubs(:scheduledTimerWithTimeInterval_target_selector_userInfo_repeats)
    
    controller.stubs(:setup_splitView!)
  end
end

describe 'ApplicationController, during awakeFromNib' do
  tests ApplicationController
  
  include ApplicationControllerSpecHelper
  
  xit "should setup the splitView so the top is hidden if necessary" do
    controller.expects(:setup_splitView!)
    controller.awakeFromNib
  end
  
  it "should set the correct default kvc values" do
    controller.stubs(:buildIndex)
    controller.awakeFromNib
    
    controller.processing.should == 0
    controller.class_tree.should == []
  end
  
  it "should initialize a Manager instance" do
    Manager.expects(:instance).returns(@manager_mock)
    controller.awakeFromNib
  end
  
  it "should set itself as the delegate of the watcher" do
    @watcher_mock.expects(:delegate=).with(controller)
    controller.awakeFromNib
  end
  
  it "should register for notifications" do
    [
      [:addObserver, controller, :selector, 'externalRequestForDocumentation:', :name, 'KariOpenDocumentation', :object, nil]
    ].each do |params|
      OSX::NSDistributedNotificationCenter.defaultCenter.expects(:objc_send).with(*params)
    end
    controller.awakeFromNib
  end
  
  it "should set a scheduled timer to signal the watcher" do
    OSX::NSTimer.expects(:scheduledTimerWithTimeInterval_target_selector_userInfo_repeats).with(5, @watcher_mock, 'signal:', nil, true)
    controller.awakeFromNib
  end
  
  it "should bootstrap the manager on first run" do
    Manager.expects(:first_run?).returns(true)
    Manager.expects(:bootstrap)
    controller.awakeFromNib
  end
  
  private
  
  def should_observe_notification(name, selector, object = nil, observer = controller)
    OSX::NSNotificationCenter.defaultCenter.expects(:addObserver_selector_name_object).with(observer, selector, name, object)
  end
end

describe "ApplicationController, when dealing with the positioning of the splitView" do
  tests ApplicationController
  
  def after_setup
    ib_outlets :classBrowser => OSX::NSBrowser.alloc.initWithFrame([0, 200, 200, 100]),
               :splitView => SplitViewWithDisableableDivider.alloc.initWithFrame([0, 20, 200, 280])
    
    window.stubs(:contentView).returns(OSX::NSView.alloc.initWithFrame(OSX::NSRect.new(0, 0, 200, 200)))
    
    splitView.vertical = false
    splitView.addSubview OSX::NSView.alloc.initWithFrame([0, 0, 200, 100]) # top
    splitView.addSubview OSX::NSView.alloc.initWithFrame([0, 109, 200, 180]) # bottom
    splitView.stubs(:super_resetCursorRects)
    
    preferences.interface.stubs(:class_browser_height).returns(classBrowser.frame.height)
  end
  
  it "should make the split view span the complete content view of the window, minus the status bar, when the `toggle class browser' button state is turned on" do
    self.class_browser_visible = true
    
    #assert_difference("splitView.frame.height", -classBrowser.frame.height) do
      assert_no_difference('controller.topViewOfSplitView.frame.height') do
        #assert_difference("controller.bottomViewOfSplitView.frame.height", -(classBrowser.frame.height + splitView.dividerThickness)) do
          controller.toggleClassBrowser(nil)
        #end
      end
    #end
  end
  
  it "should only show the bottom part of the split view when the `toggle class browser' button state is turned off" do
    set_class_browser_state_to_visible!
    self.class_browser_visible = false
    
    assert_difference('splitView.frame.height', +(classBrowser.frame.height + splitView.dividerThickness)) do
      #assert_no_difference('controller.topViewOfSplitView.frame.height') do
        assert_difference('controller.bottomViewOfSplitView.frame.height', +(classBrowser.frame.height + splitView.dividerThickness)) do
          controller.toggleClassBrowser(nil)
        end
      #end
    end
  end
  
  private
  
  def class_browser_visible=(value)
    preferences.interface.stubs(:class_browser_visible).returns(value)
  end
  
  def set_class_browser_state_to_visible!
    self.class_browser_visible = true
    controller.toggleClassBrowser(nil)
  end
end

describe 'ApplicationController, in general' do
  tests ApplicationController
  
  include ApplicationControllerSpecHelper
  include TemporaryApplicationSupportPath
  
  it "should update the `processing' state when the watcher finished indexing" do
    assigns(:processing, 0)
    
    controller.startedIndexing(nil)
    controller.valueForKey('processing').to_ruby.should.be 1
    
    controller.startedIndexing(nil)
    controller.valueForKey('processing').to_ruby.should.be 2
  end
  
  it "should update the `processing' state when the watcher finished indexing" do
    assigns(:processing, 2)
    
    controller.finishedIndexing(nil)
    controller.valueForKey('processing').to_ruby.should.be 1
    
    controller.finishedIndexing(nil)
    controller.valueForKey('processing').to_ruby.should.be 0
    
    controller.finishedIndexing(nil)
    controller.valueForKey('processing').to_ruby.should.be 0
  end
  
  it "should update the `class_tree' when the watcher finished indexing" do
    assigns(:processing, 1)
    
    nodes = [mock('ClassTreeNode')]
    ClassTreeNode.expects(:classTreeNodesWithHashTree).with(@namespace_mock).returns(nodes)
    
    controller.finishedIndexing(nil)
    controller.class_tree.should.be nodes
  end
  
  it "should keep the current selection in the class tree selected when updating the class tree" do
    assigns(:processing, 1)
    
    selection = mock('NSIndexPath')
    
    assigns(:classTreeController).expects(:selectionIndexPath).returns(selection)
    assigns(:classTreeController).expects(:setSelectionIndexPath).with(selection)
    
    controller.finishedIndexing(nil)
  end
  
  it "should cleanup the Karidocs when the watcher finished indexing" do
    assigns(:processing, 1)
    Manager.expects(:cleanup)
    controller.finishedIndexing(nil)
  end
  
  it "should set search_mode to `true' if a user started searching" do
    controller.search_mode = false
    controller.searchControllerWillStartSearching
    controller.valueForKey('search_mode').to_ruby.should.be true
  end
  
  it "should set search_mode to `false' if a user selected a search result"  do
    controller.search_mode = true
    load_url!
    controller.valueForKey('search_mode').to_ruby.should.be false
  end
  
  it "should create a special search back forward item when a switching back to the webView" do
    load_url!
    webView.backForwardList.currentItem.URLString.should == 'kari://search/ActiveRecord'
  end
  
  it "should tell the webViewController to load a file if the searchController calls its selectedFile delegate method" do
    webViewController.expects(:load_url).with('/some/file.karidoc')
    load_url! '/some/file.karidoc'
  end
  
  it "should start a new search if a search back forward item was requested" do
    searchController.expects(:search).with(searchTextField)
    controller.webView_didSelectSearchQuery(nil, 'Binding')
    searchTextField.stringValue.should == 'Binding'
  end
  
  it "should always bring the webview to the front if the loaded page is bookmarkable" do
    webViewController.stubs(:bookmarkable?).returns(true)
    controller.search_mode = true
    controller.webViewFinishedLoading(nil)
    controller.valueForKey('search_mode').to_ruby.should.be false
  end
  
  it "should close all resources when terminating" do
    assigns(:watcher, @watcher_mock)
    
    @watcher_mock.expects(:stop)
    @manager_mock.expects(:close)
    controller.applicationWillTerminate(nil)
  end
  
  it "should rebuild the index when forced from the menu" do
    assigns(:watcher, @watcher_mock)
    @watcher_mock.expects(:forceRebuild)
    controller.rebuildIndex
  end
  
  private
  
  def should_bring_webView_to_front
    webView.hidden = true
    resultsScrollView.hidden = false
    yield
    webView.hidden?.should.be false
    resultsScrollView.hidden?.should.be true
  end
  
  def load_url!(file = nil)
    controller.searchController_selectedFile(nil, file)
  end
end