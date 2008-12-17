require File.expand_path('../../test_helper', __FILE__)

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
    
    @watcher_mock = mock('Watcher')
    @watcher_mock.stubs(:delegate=)
    Watcher.stubs(:new).returns(@watcher_mock)
    
    @namespace_mock = stub('Manager#namespace')
    @namespace_mock.stubs(:tree).returns({})
    @manager_mock.stubs(:namespace).returns(@namespace_mock)
    
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
  
  it "should register for notications" do
    [
      [:addObserver, controller, :selector, 'externalRequestForDocumentation:', :name, 'KariOpenDocumentation', :object, nil],
      [:addObserver, controller, :selector, 'finishedIndexing:', :name, 'KariDidFinishIndexing', :object, nil]
    ].each do |params|
      OSX::NSDistributedNotificationCenter.defaultCenter.expects(:objc_send).with(*params)
    end
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
               :splitView => OSX::NSSplitView.alloc.initWithFrame([0, 0, 200, 200])
    
    window.stubs(:contentView).returns(OSX::NSView.alloc.initWithFrame(OSX::NSRect.new(0, 0, 200, 200)))
    
    splitView.vertical = false
    2.times { splitView.addSubview OSX::NSView.alloc.initWithFrame([0, 0, 200, 100]) }
  end
  
  it "should make the split view span the complete content view of the window, minus the status bar, when the `toggle class browser' button state is turned on" do
    expected_split_view_frame = window.contentView.frame.dup
    expected_split_view_frame.height -= ApplicationController::STATUS_BAR_HEIGHT
    expected_split_view_frame.y += ApplicationController::STATUS_BAR_HEIGHT
    
    should_animate_scrollView_to_frame(expected_split_view_frame)
    controller.toggleClassBrowser(button(OSX::NSOnState))
  end
  
  it "should only show the bottom part of the split view when the `toggle class browser' button state is turned off" do
    expected_split_view_frame = window.contentView.frame.dup
    expected_split_view_frame.height += (100 + splitView.dividerThickness)
    
    should_animate_scrollView_to_frame(expected_split_view_frame)
    controller.toggleClassBrowser(button(OSX::NSOffState))
  end
  
  private
  
  def should_animate_scrollView_to_frame(expected_split_view_frame)
    OSX::NSValue.expects(:valueWithRect).with do |new_split_view_frame|
      unless new_split_view_frame == expected_split_view_frame
        puts "New splitView frame: #{new_split_view_frame.inspect}\ndoes not match expected frame: #{expected_split_view_frame.inspect}"
      end
      new_split_view_frame == expected_split_view_frame
    end.returns(expected_split_view_frame.inspect)
    
    expected_split_view_animation = { OSX::NSViewAnimationTargetKey => splitView, OSX::NSViewAnimationEndFrameKey => expected_split_view_frame.inspect }
    controller.expects(:animate).with(expected_split_view_animation)
  end
  
  def button(state)
    button = OSX::NSButton.alloc.init
    button.state = state
    button
  end
end

describe 'ApplicationController, in general' do
  tests ApplicationController
  
  include ApplicationControllerSpecHelper
  include TemporaryApplicationSupportPath
  
  it "should update the `processing' state when a `KariDidStartIndexingNotification' is received" do
    assigns(:processing, 0)
    
    controller.startedIndexing(nil)
    controller.valueForKey('processing').to_ruby.should.be 1
    
    controller.startedIndexing(nil)
    controller.valueForKey('processing').to_ruby.should.be 2
  end
  
  it "should update the `processing' state when a `KariDidFinishIndexingNotification' is received" do
    assigns(:processing, 2)
    
    controller.finishedIndexing(nil)
    controller.valueForKey('processing').to_ruby.should.be 1
    
    controller.finishedIndexing(nil)
    controller.valueForKey('processing').to_ruby.should.be 0
    
    controller.finishedIndexing(nil)
    controller.valueForKey('processing').to_ruby.should.be 0
  end
  
  it "should update the `class_tree' when a `KariDidFinishIndexingNotification' is received" do
    assigns(:processing, 1)
    
    nodes = [mock('ClassTreeNode')]
    ClassTreeNode.expects(:classTreeNodesWithHashTree).with(@namespace_mock).returns(nodes)
    
    controller.finishedIndexing(nil)
    controller.class_tree.should.be nodes
  end
  
  it "should bring the results table view forward and hide the webView if a user started searching" do
    start_searching!
    webView.hidden?.should.be true
    resultsScrollView.hidden?.should.be false
  end
  
  xit "should load a blank web page, otherwise the last loaded page will be visible for a split second when hiding the search results table view" do
    webViewController.expects(:blank!)
    start_searching!
  end
  
  it "should create a special search back forward item when a switching back to the webView" do
    load_url!
    webView.backForwardList.currentItem.URLString.should == 'kari://search/ActiveRecord'
  end
  
  it "should tell the webViewController to load a file if the searchController calls its selectedFile delegate method" do
    webViewController.expects(:load_url).with('/some/file.karidoc')
    load_url! '/some/file.karidoc'
  end
  
  it "should bring the webView forward and hide the results table view if a user selected a search result"  do
    should_bring_webView_to_front do
      load_url!
    end
  end
  
  it "should start a new search if a search back forward item was requested" do
    searchController.expects(:search).with(searchTextField)
    controller.webView_didSelectSearchQuery(nil, 'Binding')
    searchTextField.stringValue.should == 'Binding'
  end
  
  it "should always bring the webview to the front if the loaded page is bookmarkable" do
    webViewController.stubs(:bookmarkable?).returns(true)
    should_bring_webView_to_front do
      controller.webViewFinishedLoading(nil)
    end
    
    webView.hidden = true
    webViewController.stubs(:bookmarkable?).returns(false)
    webView.hidden?.should.be true
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
  
  def start_searching!
    controller.searchControllerWillStartSearching
  end
  
  def load_url!(file = nil)
    controller.searchController_selectedFile(nil, file)
  end
end