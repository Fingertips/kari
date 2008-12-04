require File.expand_path('../../test_helper', __FILE__)

xdescribe "ApplicationController, when a bookmarkBarToggledVisibility notification is received" do
  tests ApplicationController
  
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

describe 'ApplicationController, in general' do
  tests ApplicationController
  
  def after_setup
    ib_outlets :webViewController => WebViewController.alloc.init,
               :webView => OSX::WebView.alloc.init,
               :resultsScrollView => OSX::NSScrollView.alloc.init,
               :searchTextField => OSX::NSSearchField.alloc.init
    
    webViewController.instance_variable_set(:@webview, webView)
    webViewController.stubs(:load_file)
    
    searchTextField.stringValue = 'ActiveRecord'
    
    @manager_mock = mock('Manager')
    Manager.stubs(:initialize_from_disk).returns(@manager_mock)
    assigns(:manager, @manager_mock)
  end
  
  it "should initialize a Manager instance and call #buildIndex" do
    Manager.expects(:initialize_from_disk)
    controller.expects(:buildIndex)
    controller.awakeFromNib
  end
  
  it "should start the merge new docs process in a new thread and update the `processing' state to reflect this" do
    controller.awakeFromNib
    
    Thread.expects(:new).yields
    @manager_mock.expects(:merge_new)
    
    controller.buildIndex
    
    controller.valueForKey('processing').to_ruby.should.be true
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