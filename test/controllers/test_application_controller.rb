require File.expand_path('../../test_helper', __FILE__)

describe 'ApplicationController' do
  before do
    shared_app_mock = mock("sharedApplication")
    shared_app_mock.stubs(:setDelegate)
    OSX::NSApplication.stubs(:sharedApplication).returns(shared_app_mock)
    
    @controller = ApplicationController.alloc.init
    
    # Maybe with Rucola we should stub every ib_outlet ?
    # (s = stub).stub_everything
    # @controller.instance_variable_set(:@searchProgressIndicator, s)
    (s = stub).stub_everything
    @controller.instance_variable_set(:@webViewController, s)
  end
  
  it "should set itself as the application delegate and instantiate an instance of Backend on init" do
    @controller.should.be.an.instance_of ApplicationController
  end
  
  # it "should assign itself as the delegate for multiple controllers on awakeFromNib" do
  #   window_mock = mock("Window")
  #   @controller.instance_variable_set(:@searchTextField, 'search text field')
  #   window_mock.expects(:makeFirstResponder).with('search text field')
  #   
  #   bookmark_controller_mock = mock("BookmarkController")
  #   bookmark_controller_mock.expects(:delegate=).with(@controller)
  #   @controller.instance_variable_set(:@bookmarkController, bookmark_controller_mock)
  # 
  #   webview_controller_mock = mock("WebViewController")
  #   webview_controller_mock.expects(:delegate=).with(@controller)
  #   webview_controller_mock.expects(:home)
  #   @controller.instance_variable_set(:@webViewController, webview_controller_mock)
  #   
  #   window_mock.expects(:delegate=).with(@controller)
  #   @controller.instance_variable_set(:@window, window_mock)
  #   
  #   @controller.awakeFromNib
  # end
  
  # it "should change the startup status message if it's the first run and it's building the index" do
  #   @controller.ib_outlet(:statusMessage).expects(:stringValue=).with('Indexing documentation')
  #   @controller.backendDidStartFirstIndexing(nil)
  # end

  # FIXME: Backend related
  # it "should pass a query url on to the webview controller" do
  #   query = "Time".to_ns
  #   search_field_mock = mock("SearchField")
  #   search_field_mock.expects(:stringValue).and_return(query)
  #   
  #   progress_indicator_mock = mock("Progress Indicator")
  #   progress_indicator_mock.expects(:startAnimation)
  #   @controller.instance_variable_set(:@searchProgressIndicator, progress_indicator_mock)
  #   
  #   webview_controller_mock = mock("WebViewController")
  #   webview_controller_mock.expects(:search).with(query)
  #   @controller.instance_variable_set(:@webViewController, webview_controller_mock)
  #   
  #   @controller.search(search_field_mock)
  # end
  
  it "should bring the results table view forward and hide the webview if a user started searching" do
    ib_outlet(:searchProgressIndicator).expects(:startAnimation)
    ib_outlet(:webView).expects(:hidden=).with(true)
    ib_outlet(:webViewController).expects(:blank!)
    ib_outlet(:resultsScrollView).expects(:hidden=).with(false)
    @controller.searchControllerWillStartSearching
  end
  
  it "should tell the webViewController to load a file if the searchController calls its selectedFile delegate method" do
    ib_outlet(:webViewController).expects(:load_file).with('/some/file.karidoc')
    ib_outlet(:webView).expects(:hidden=).with(false)
    ib_outlet(:resultsScrollView).expects(:hidden=).with(true)
    @controller.searchController_selectedFile(nil, '/some/file.karidoc')
  end
  
  it "should bring the webview back if a search result was double clicked" do
    ib_outlet(:webView).expects(:hidden=).with(false)
    ib_outlet(:resultsScrollView).expects(:hidden=).with(true)
    @controller.searchController_selectedFile(nil, nil)
  end
  
  private
  
  def ib_outlet(name)
    @controller.ib_outlet(name)
  end
end