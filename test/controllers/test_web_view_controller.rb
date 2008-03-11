require File.expand_path('../../test_helper', __FILE__)

module WebViewControllerSpecHelper
  def setup_webview
    @webview_mock = mock("WebView")
    @webview_controller = WebViewController.alloc.init
    @webview_controller.instance_variable_set :@webview, @webview_mock
    
    @mainframe_mock = mock("WebView mainFrame")
    @webview_mock.stubs(:mainFrame).returns(@mainframe_mock)
  end
  
  def expects_load_url_with_url_that_matches(should_be_url)
    @webview_controller.expects(:load_url).with do |url|
      url.absoluteString.to_s =~ should_be_url
    end
  end
end

describe 'WebViewController, in general' do
  include WebViewControllerSpecHelper
  
  before do
    setup_webview
    
    @file = '/some/path/to/a/file.karidoc'
    @file_url = /file:\/\/.*#{@file}/
  end

  it "should take a NSURL instance and load it in the webview" do
    @mainframe_mock.expects(:loadRequest).with do |request|
      request.URL.absoluteString.to_s =~ @file_url
    end
    @webview_controller.load_url OSX::NSURL.fileURLWithPath(@file)
  end

  it "should take a string URL, create a NSURL and load it in the webview" do
    @mainframe_mock.expects(:loadRequest).with do |request|
      request.URL.absoluteString.to_s =~ @file_url
    end
    @webview_controller.load_url "file://#{@file}"
  end

  it "should take a string file path, create a NSURL and send it to load_url" do
    expects_load_url_with_url_that_matches(@file_url)
    @webview_controller.load_file(@file)
  end
  
  it "should set the doc_title to the title of the page" do
    @webview_controller.doc_title.should == ''
    
    @webview_controller.webView_didReceiveTitle_forFrame(nil, 'some title', nil)
    @webview_controller.doc_title.should == 'some title'
  end
end

describe 'WebViewController, helper methods' do
  include WebViewControllerSpecHelper
  
  before do
    setup_webview
  end
  
  it "should load the index.html page" do
    expects_load_url_with_url_that_matches(/file:\/\/localhost\/.+\/app\/assets\/index.html$/)
    @webview_controller.home!
  end
  
  it "should load a blank page" do
    expects_load_url_with_url_that_matches(/^about:blank$/)
    @webview_controller.blank!
  end
end