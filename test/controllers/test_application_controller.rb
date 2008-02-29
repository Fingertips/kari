require File.expand_path('../../test_helper', __FILE__)

describe 'ApplicationController' do
  before do
    shared_app_mock = mock("sharedApplication")
    shared_app_mock.stubs(:setDelegate)
    OSX::NSApplication.stubs(:sharedApplication).returns(shared_app_mock)
    
    @app_controller = ApplicationController.alloc.init
    
    # Maybe with Rucola we should stub every ib_outlet ?
    # (s = stub).stub_everything
    # @app_controller.instance_variable_set(:@searchProgressIndicator, s)
    (s = stub).stub_everything
    @app_controller.instance_variable_set(:@webViewController, s)
  end
  
  it "should set itself as the application delegate and instantiate an instance of Backend on init" do
    @app_controller.should.be.an.instance_of ApplicationController
  end
  
  it "should assign itself as the delegate for multiple controllers on awakeFromNib" do
    window_mock = mock("Window")
    @app_controller.instance_variable_set(:@searchTextField, 'search text field')
    window_mock.expects(:makeFirstResponder).with('search text field')
    
    bookmark_controller_mock = mock("BookmarkController")
    bookmark_controller_mock.expects(:delegate=).with(@app_controller)
    @app_controller.instance_variable_set(:@bookmarkController, bookmark_controller_mock)

    webview_controller_mock = mock("WebViewController")
    webview_controller_mock.expects(:delegate=).with(@app_controller)
    webview_controller_mock.expects(:home)
    @app_controller.instance_variable_set(:@webViewController, webview_controller_mock)
    
    window_mock.expects(:delegate=).with(@app_controller)
    @app_controller.instance_variable_set(:@window, window_mock)
    
    @app_controller.awakeFromNib
  end
  
  # it "should change the startup status message if it's the first run and it's building the index" do
  #   @app_controller.ib_outlet(:statusMessage).expects(:stringValue=).with('Indexing documentation')
  #   @app_controller.backendDidStartFirstIndexing(nil)
  # end

  # FIXME: Backend related
  # it "should pass a query url on to the webview controller" do
  #   query = "Time".to_ns
  #   search_field_mock = mock("SearchField")
  #   search_field_mock.expects(:stringValue).and_return(query)
  #   
  #   progress_indicator_mock = mock("Progress Indicator")
  #   progress_indicator_mock.expects(:startAnimation)
  #   @app_controller.instance_variable_set(:@searchProgressIndicator, progress_indicator_mock)
  #   
  #   webview_controller_mock = mock("WebViewController")
  #   webview_controller_mock.expects(:search).with(query)
  #   @app_controller.instance_variable_set(:@webViewController, webview_controller_mock)
  #   
  #   @app_controller.search(search_field_mock)
  # end
  
  it "should bring the results table view forward and hide the webview if a user started searching" do
    ib_outlet(:searchProgressIndicator).expects(:startAnimation)
    ib_outlet(:webView).expects(:hidden=).with(true)
    ib_outlet(:webViewController).expects(:blank)
    ib_outlet(:resultsScrollView).expects(:hidden=).with(false)
    @app_controller.searchControllerWillStartSearching
  end
  
  it "should bring the webview back if a search result was double clicked" do
    ib_outlet(:webView).expects(:hidden=).with(false)
    ib_outlet(:resultsScrollView).expects(:hidden=).with(true)
    @app_controller.searchControllerSelectedURL(nil)
  end
  
  private
  
  def ib_outlet(name)
    @app_controller.ib_outlet(name)
  end
end