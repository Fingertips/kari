require File.expand_path('../../test_helper', __FILE__)

describe 'ApplicationController' do
  tests ApplicationController
  
  def after_setup
    ib_outlets :resultsScrollView => OSX::NSScrollView.alloc.init,
               :webView => OSX::WebView.alloc.init
  end
  
  it "should bring the results table view forward and hide the webview if a user started searching" do
    controller.searchControllerWillStartSearching
    webView.hidden?.should.be true
    resultsScrollView.hidden?.should.be false
  end
  
  it "should load a blank web page, otherwise the last loaded page will be visible for a split second when hidding the search results table view" do
    webViewController.expects(:blank!)
    controller.searchControllerWillStartSearching
  end
  
  it "should tell the webViewController to load a file if the searchController calls its selectedFile delegate method" do
    webViewController.expects(:load_file).with('/some/file.karidoc')
    controller.searchController_selectedFile(nil, '/some/file.karidoc')
  end
  
  it "should bring the webview forward and hide the results table view if a user selected a search result"  do
    controller.searchController_selectedFile(nil, nil)
    webView.hidden?.should.be false
    resultsScrollView.hidden?.should.be true
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