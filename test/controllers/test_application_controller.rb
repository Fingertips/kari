require File.expand_path('../../test_helper', __FILE__)

describe 'ApplicationController' do
  tests ApplicationController
  
  def after_setup
    ib_outlets :webViewController => WebViewController.alloc.init,
               :webView => OSX::WebView.alloc.init,
               :resultsScrollView => OSX::NSScrollView.alloc.init,
               :searchTextField => OSX::NSSearchField.alloc.init
    
    webViewController.instance_variable_set(:@webview, webView)
    webViewController.stubs(:load_file)
    
    searchTextField.stringValue = 'ActiveRecord'
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

# OLD, might need to put some tests back.

# describe 'ApplicationController' do
#   before do
#     shared_app_mock = mock("sharedApplication")
#     shared_app_mock.stubs(:setDelegate)
#     OSX::NSApplication.stubs(:sharedApplication).returns(shared_app_mock)
#     
#     @controller = ApplicationController.alloc.init
#     
#     # Maybe with Rucola we should stub every ib_outlet ?
#     # (s = stub).stub_everything
#     # @controller.instance_variable_set(:@searchProgressIndicator, s)
#     (s = stub).stub_everything
#     @controller.instance_variable_set(:@webViewController, s)
#   end
#   
#   it "should assign itself as the delegate for multiple controllers on awakeFromNib" do
#     window_mock = mock("Window")
#     @controller.instance_variable_set(:@searchTextField, 'search text field')
#     window_mock.expects(:makeFirstResponder).with('search text field')
#     
#     bookmark_controller_mock = mock("BookmarkController")
#     bookmark_controller_mock.expects(:delegate=).with(@controller)
#     @controller.instance_variable_set(:@bookmarkController, bookmark_controller_mock)
#   
#     webview_controller_mock = mock("WebViewController")
#     webview_controller_mock.expects(:delegate=).with(@controller)
#     webview_controller_mock.expects(:home)
#     @controller.instance_variable_set(:@webViewController, webview_controller_mock)
#     
#     window_mock.expects(:delegate=).with(@controller)
#     @controller.instance_variable_set(:@window, window_mock)
#     
#     @controller.awakeFromNib
#   end
#   
#   it "should change the startup status message if it's the first run and it's building the index" do
#     @controller.ib_outlet(:statusMessage).expects(:stringValue=).with('Indexing documentation')
#     @controller.backendDidStartFirstIndexing(nil)
#   end
# 
#   FIXME: Backend related
#   it "should pass a query url on to the webview controller" do
#     query = "Time".to_ns
#     search_field_mock = mock("SearchField")
#     search_field_mock.expects(:stringValue).and_return(query)
#     
#     progress_indicator_mock = mock("Progress Indicator")
#     progress_indicator_mock.expects(:startAnimation)
#     @controller.instance_variable_set(:@searchProgressIndicator, progress_indicator_mock)
#     
#     webview_controller_mock = mock("WebViewController")
#     webview_controller_mock.expects(:search).with(query)
#     @controller.instance_variable_set(:@webViewController, webview_controller_mock)
#     
#     @controller.search(search_field_mock)
#   end
# end