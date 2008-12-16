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
  end
end

describe 'ApplicationController, during awakeFromNib' do
  tests ApplicationController
  
  include ApplicationControllerSpecHelper
  
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
  
  private
  
  def should_observe_notification(name, selector, object = nil, observer = controller)
    OSX::NSNotificationCenter.defaultCenter.expects(:addObserver_selector_name_object).with(observer, selector, name, object)
  end
end

describe "ApplicationController, when toggling the class browser visibility" do
  tests ApplicationController
  
  def after_setup
    ib_outlets :webView => OSX::NSView.alloc.initWithFrame([0, 0, 200, 200]),
               :resultsScrollView => OSX::NSScrollView.alloc.initWithFrame([0, 0, 200, 200]),
               :classBrowser => OSX::NSBrowser.alloc.initWithFrame([0, 200, 200, 135])
    
    window.stubs(:frame).returns(OSX::NSRect.new(0, 0, 200, 200))
    OSX::NSViewAnimation.any_instance.stubs(:startAnimation)
    @views = %w{ resultsScrollView classBrowser webView }
  end
  
  it "should return a hash with animation properties for a view, which makes the view end up at the same Y position as before (basically moving the view)" do
    OSX::NSValue.stubs(:valueWithRect).with(webView.frame).returns(webView.frame.inspect)
    controller.send(:move_view, webView).should == { OSX::NSViewAnimationTargetKey => webView, OSX::NSViewAnimationEndFrameKey => webView.frame.inspect }
  end
  
  it "should enlarge the window to show the browser when the `toggle class browser' button state is off" do
    stub_view_animations!
    
    expected_window_frame = window.frame.dup
    expected_window_frame.height -= 135
    expected_window_frame.y += 135
    
    OSX::NSValue.expects(:valueWithRect).with do |new_window_frame|
      new_window_frame == expected_window_frame
    end.returns(expected_window_frame.inspect)
    
    expected_window_animation = { OSX::NSViewAnimationTargetKey => window, OSX::NSViewAnimationEndFrameKey => expected_window_frame.inspect }
    controller.expects(:animate).with(expected_window_animation, *@views)
    
    button = OSX::NSButton.alloc.init
    button.state = OSX::NSOffState
    controller.toggleClassBrowser(OSX::NSButton.alloc.init)
  end
  
  it "should shrink the window to hide the browser when the `toggle class browser' button state is on" do
    stub_view_animations!
    
    expected_window_frame = window.frame.dup
    expected_window_frame.height += 135
    expected_window_frame.y -= 135
    
    OSX::NSValue.expects(:valueWithRect).with do |new_window_frame|
      new_window_frame == expected_window_frame
    end.returns(expected_window_frame.inspect)
    
    expected_window_animation = { OSX::NSViewAnimationTargetKey => window, OSX::NSViewAnimationEndFrameKey => expected_window_frame.inspect }
    controller.expects(:animate).with(expected_window_animation, *@views)
    
    button = OSX::NSButton.alloc.init
    button.state = OSX::NSOnState
    controller.toggleClassBrowser(button)
  end
  
  private
  
  def stub_view_animations!
    @views.each do |view|
      controller.stubs(:move_view).with(eval(view)).returns(view)
    end
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