require File.expand_path('../../test_helper', __FILE__)

# Need to get at the defined ib_outlets and setup mocks for each one.
class OSX::NSObject
  def assigns(name, value = nil)
    if value.nil?
      instance_variable_get("@#{name}".to_sym)
    else
      instance_variable_set("@#{name}", value)
    end
  end
end

module WebViewControllerSpecHelper
  def setup_webview
    @webview_mock = mock("WebView")
    @controller = WebViewController.alloc.init
    @controller.instance_variable_set :@webview, @webview_mock
    
    @mainframe_mock = mock("WebView mainFrame")
    @webview_mock.stubs(:mainFrame).returns(@mainframe_mock)
  end
  
  def expects_load_url_with_url_that_matches(should_be_url)
    @controller.expects(:load_url).with do |url|
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
    @controller.load_url OSX::NSURL.fileURLWithPath(@file)
  end

  it "should take a string URL, create a NSURL and load it in the webview" do
    @mainframe_mock.expects(:loadRequest).with do |request|
      request.URL.absoluteString.to_s =~ @file_url
    end
    @controller.load_url "file://#{@file}"
  end

  it "should take a string file path, create a NSURL and send it to load_url" do
    expects_load_url_with_url_that_matches(@file_url)
    @controller.load_file(@file)
  end
  
  it "should set the doc_title to the title of the page" do
    @controller.doc_title.should == ''
    
    @controller.webView_didReceiveTitle_forFrame(nil, 'some title', nil)
    @controller.doc_title.should == 'some title'
  end
end

describe 'WebViewController, helper methods' do
  include WebViewControllerSpecHelper
  
  before do
    setup_webview
  end
  
  it "should load the index.html page" do
    expects_load_url_with_url_that_matches(/file:\/\/localhost\/.+\/app\/assets\/index.html$/)
    @controller.home!
  end
  
  it "should load a blank page" do
    expects_load_url_with_url_that_matches(/^about:blank$/)
    @controller.blank!
  end
  
  it "should know if the current page is bookmarkable" do
    @controller.stubs(:url).returns('file:///some/path/file.karidoc')
    
    assigns(:webview).stubs(:hidden?).returns(false)
    @controller.should.be.bookmarkable
    
    assigns(:webview).stubs(:hidden?).returns(true)
    @controller.should.not.be.bookmarkable
    
    @controller.stubs(:url).returns('file:///some/path/Kari.app/Contents/Resources/app/assets/index.html')
    
    assigns(:webview).stubs(:hidden?).returns(false)
    @controller.should.not.be.bookmarkable
    
    assigns(:webview).stubs(:hidden?).returns(true)
    @controller.should.not.be.bookmarkable
  end
  
  private
  
  def assigns(name, value = nil)
    @controller.assigns(name, value)
  end
end