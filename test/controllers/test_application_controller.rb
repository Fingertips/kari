require File.expand_path('../../test_helper', __FILE__)

xdescribe "ApplicationController, when a bookmarkBarToggledVisibility notification is received" do
  tests ApplicationController
  
  before(:all) do
    OSX::NSUserDefaults.stubs(:standardUserDefaults).returns(stub(:registerDefaults => true))
  end
  
  def after_setup
    ib_outlets :webView => OSX::NSView.alloc.initWithFrame([0, 20, 100, 100]),
               :resultsScrollView => OSX::NSScrollView.alloc.initWithFrame([0, 20, 100, 100])
    
    window.stubs(:frame).returns(OSX::NSRect.new(0, 0, 100, 100))
    @bookmarkBar = OSX::NSView.alloc.initWithFrame([0, 0, 100, 20])
  end
  
  it "should resize the window to shrink if the bookmark bar is hidden" do
    @bookmarkBar.hidden = true
    should_resize_window_height :from => 100, :to => 80
    controller.bookmarkBarToggledVisibility(@bookmarkBar)
  end
  
  it "should resize the window to grow if the bookmark bar is not hidden" do
    @bookmarkBar.hidden = false
    should_resize_window_height :from => 80, :to => 100
    controller.bookmarkBarToggledVisibility(@bookmarkBar)
  end
  
  %w{ webView resultsScrollView }.each do |view|
    
    it "should increase the height of the #{view} if the bookmark bar is hidden" do
      @bookmarkBar.hidden = true
      assert_difference("#{view}.frame.height", +20) do
        controller.bookmarkBarToggledVisibility(@bookmarkBar)
      end
    end
    
    it "should decrease the height of the #{view} if the bookmark bar is not hidden" do
      @bookmarkBar.hidden = false
      assert_difference("#{view}.frame.height", -20) do
        controller.bookmarkBarToggledVisibility(@bookmarkBar)
      end
    end
    
  end
  
  private
  
  def should_resize_window_height(options)
    window.stubs(:frame).returns(OSX::NSRect.new(0, 0, 100, options[:from]))
    window.expects(:setFrame_display_animate).with do |new_frame, display, animate|
      display && animate && new_frame.width == 100 and new_frame.height == options[:to]
    end
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
    Manager.stubs(:initialize_from_disk).returns(@manager_mock)
    
    @watcher_mock = mock('Watcher')
    @watcher_mock.stubs(:buildIndex)
    Watcher.stubs(:new).returns(@watcher_mock)
    
    @namespace_mock = stub('Manager#namespace')
    @namespace_mock.stubs(:tree).returns({})
    @manager_mock.stubs(:namespace).returns(@namespace_mock)
  end
end

describe 'ApplicationController, during awakeFromNib' do
  tests ApplicationController
  
  include ApplicationControllerSpecHelper
  
  before(:all) do
    OSX::NSUserDefaults.stubs(:standardUserDefaults).returns(stub(:registerDefaults => true))
  end
  
  it "should set the correct default kvc values" do
    controller.stubs(:buildIndex)
    controller.awakeFromNib
    
    controller.processing.should == 0
    controller.class_tree.should == []
  end
  
  it "should initialize a Manager instance" do
    Manager.expects(:initialize_from_disk).returns(@manager_mock)
    controller.awakeFromNib
  end
  
  it "should register itself as an observer for the `KariDidFinishIndexingNotification' notification" do
    should_observe_notification('KariDidStartIndexingNotification', 'startedIndexing:')
    should_observe_notification('KariDidFinishIndexingNotification', 'finishedIndexing:')
    controller.awakeFromNib
  end
  
  private
  
  def should_observe_notification(name, selector, object = nil, observer = controller)
    OSX::NSNotificationCenter.defaultCenter.expects(:addObserver_selector_name_object).with(observer, selector, name, object)
  end
end

describe 'ApplicationController, in general' do
  tests ApplicationController
  
  include ApplicationControllerSpecHelper
  include TemporaryApplicationSupportPath
  
  before do
    OSX::NSUserDefaults.stubs(:standardUserDefaults).returns({})
  end
  
  it "should update the `processing' state when a `KariDidStartIndexingNotification' is received" do
    assigns(:manager, @manager_mock)
    assigns(:processing, 0)
    
    controller.startedIndexing(nil)
    controller.valueForKey('processing').to_ruby.should.be 1
    
    controller.startedIndexing(nil)
    controller.valueForKey('processing').to_ruby.should.be 2
  end
  
  it "should update the `processing' state when a `KariDidFinishIndexingNotification' is received" do
    assigns(:manager, @manager_mock)
    assigns(:processing, 2)
    
    controller.finishedIndexing(nil)
    controller.valueForKey('processing').to_ruby.should.be 1
    
    controller.finishedIndexing(nil)
    controller.valueForKey('processing').to_ruby.should.be 0
    
    controller.finishedIndexing(nil)
    controller.valueForKey('processing').to_ruby.should.be 0
  end
  
  it "should update the `class_tree' when a `KariDidFinishIndexingNotification' is received" do
    assigns(:manager, @manager_mock)
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
    select_file!
    webView.backForwardList.currentItem.URLString.should == 'kari://search/ActiveRecord'
  end
  
  it "should tell the webViewController to load a file if the searchController calls its selectedFile delegate method" do
    webViewController.expects(:load_file).with('/some/file.karidoc')
    select_file! '/some/file.karidoc'
  end
  
  it "should bring the webView forward and hide the results table view if a user selected a search result"  do
    should_bring_webView_to_front do
      select_file!
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
    assigns(:manager, @manager_mock)
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
  
  def select_file!(file = nil)
    controller.searchController_selectedFile(nil, file)
  end
end