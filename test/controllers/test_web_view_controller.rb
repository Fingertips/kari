require File.expand_path('../../test_helper', __FILE__)

module WebViewControllerSpecHelper
  def expects_load_url_with_url_that_matches(should_be_url)
    controller.expects(:load_url).with do |url|
      url.absoluteString.to_s =~ should_be_url
    end
  end
end

describe 'WebViewController, in general' do
  tests WebViewController
  
  include WebViewControllerSpecHelper
  
  def after_setup
    @mainframe = mock("WebView mainFrame")
    webview.stubs(:mainFrame).returns(@mainframe)
    
    @file = '/some/path/to/a/file.karidoc'
    @file_url = /file:\/\/.*#{@file}/
  end

  it "should take a NSURL instance and load it in the webview" do
    @mainframe.expects(:loadRequest).with do |request|
      request.URL.absoluteString.to_s =~ @file_url
    end
    controller.load_url OSX::NSURL.fileURLWithPath(@file)
  end

  it "should take a ruby string URL, create a NSURL and load it in the webview" do
    @mainframe.expects(:loadRequest).with do |request|
      request.URL.absoluteString.to_s =~ @file_url
    end
    controller.load_url "file://#{@file}"
  end

  it "should take a NSString URL, create a NSURL and load it in the webview" do
    @mainframe.expects(:loadRequest).with do |request|
      request.URL.absoluteString.to_s =~ @file_url
    end
    controller.load_url "file://#{@file}".to_ns
  end

  it "should take a string file path, create a NSURL and send it to load_url" do
    expects_load_url_with_url_that_matches(@file_url)
    controller.load_file(@file)
  end
  
  it "should set the doc_title to the title of the page" do
    controller.doc_title.should == ''
    
    controller.webView_didReceiveTitle_forFrame(nil, 'some title', nil)
    controller.doc_title.should == 'some title'
  end
end

describe 'WebViewController, helper methods' do
  tests WebViewController
  
  include WebViewControllerSpecHelper
  
  it "should load the index.html page" do
    expects_load_url_with_url_that_matches(/file:\/\/localhost\/.+\/app\/assets\/index.html$/)
    controller.home!
  end
  
  it "should load a blank page" do
    expects_load_url_with_url_that_matches(/^about:blank$/)
    controller.blank!
  end
  
  it "should know if the current page is bookmarkable" do
    controller.stubs(:url).returns(nil)
    
    webview.stubs(:hidden?).returns(false)
    controller.should.not.be.bookmarkable
    
    webview.stubs(:hidden?).returns(true)
    controller.should.not.be.bookmarkable
    
    controller.stubs(:url).returns('file:///some/path/file.karidoc')
    
    webview.stubs(:hidden?).returns(false)
    controller.should.be.bookmarkable
    
    webview.stubs(:hidden?).returns(true)
    controller.should.not.be.bookmarkable
    
    controller.stubs(:url).returns('file:///some/path/Kari.app/Contents/Resources/app/assets/index.html')
    
    webview.stubs(:hidden?).returns(false)
    controller.should.not.be.bookmarkable
    
    webview.stubs(:hidden?).returns(true)
    controller.should.not.be.bookmarkable
  end
end

Thread.new { OSX::CFRunLoopRun }

describe "WebViewController, when dealing with special back/forward items" do
  tests WebViewController
  
  def after_setup
    ib_outlets :webview => OSX::WebView.alloc.init
  end
  
  it "should create a new WebHistoryItem representing a search query" do
    controller.add_search_back_forward_item('string')
    webview.backForwardList.currentItem.URLString.should == 'kari://search/string'
  end
end