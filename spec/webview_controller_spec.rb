require File.dirname(File.expand_path(__FILE__)) + "/../WebViewController.rb"

describe WebViewController do
  before do
    @webview_mock = mock("WebView")    
    @webview_controller = WebViewController.alloc.init
    @webview_controller.instance_variable_set :@webview, @webview_mock
  end
  
  it "should create a NSURLRequest for a ruby string" do
    url = "http://127.0.0.1:9999"
    @webview_controller.instance_variable_set :@port, 9999
    result = @webview_controller.url_request(url)
    result.should be_instance_of(OSX::NSURLRequest)
    result.URL.absoluteString.should == url
  end
  
  it "should load a given url in it's webview" do
    mainFrame_mock = mock("WebView mainFrame")
    urlrequest_mock = mock("NSURLRequest")
    @webview_controller.should_receive(:url_request).and_return(urlrequest_mock)
    mainFrame_mock.should_receive(:loadRequest).with(urlrequest_mock)
    @webview_mock.should_receive(:mainFrame).and_return(mainFrame_mock)
    
    @webview_controller.load_url "http://127.0.0.1:9999"
  end
  
  # it "should load a url in the webview" do
  #   #urlrequest_mock = mock("NSURLRequest")
  #   #urlrequest_mock.should_receive(:requestWithURL)
  #   OSX::NSURLRequest.requestWithURL
  #   (OSX::NSURL.URLWithString(url))
  #   
  #   webview_mainframe_mock = mock("WebView mainFrame")
  #   webview_mainframe_mock.should_receive(:loadRequest).once.with(urlrequest_mock)
  #   @app_controller.instance_variable_get(:@webview_controller).should_receive(:load_url)
  #   
  #   @app_controller.load_url "http://127.0.0.1:9999"
  #   
  # end
  
end