require File.expand_path('../../test_helper', __FILE__)

module WebViewControllerSpecHelper
  def expects_load_url_with_url_that_matches(should_be_url)
    controller.expects(:load_url).with do |url|
      url.absoluteString.to_s =~ should_be_url
    end
  end
end

describe "WebViewController, when initializing" do
  tests WebViewController
  
  def after_setup
    ib_outlets :webview => OSX::WebView.alloc.init
    controller.awakeFromNib
  end

  it "should enable the tabsToLinks preference" do
    webview.objc_send(:preferences).tabsToLinks.should.be 1
  end
end

describe 'WebViewController, in general' do
  tests WebViewController
  
  include WebViewControllerSpecHelper
  
  def after_setup
    ib_outlets :cursorOverLinkTextField => OSX::NSTextField.alloc.init
    
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
  
  it "should show the rubyname of a link that a user is hovering the cursor over in the status bar if it's a karidoc" do
    url = OSX::NSURL.fileURLWithPath(File.join(Manager.current_filepath, 'Mutex/#exclusive_unlock.karidoc'))
    
    controller.webView_mouseDidMoveOverElement_modifierFlags(nil, { 'WebElementLinkURL' => url }, nil)
    cursorOverLinkTextField.stringValue.should == 'Mutex#exclusive_unlock'
  end
  
  it "should show the full URL of a link a user is hovering the cursor over in the status bar if it's not to a karidoc" do
    url = OSX::NSURL.URLWithString("http://www.fngtps.com")
    controller.webView_mouseDidMoveOverElement_modifierFlags(nil, { 'WebElementLinkURL' => url }, nil)
    cursorOverLinkTextField.stringValue.should == url.absoluteString
  end
  
  it "should empty the link a user is hovering over from the status bar if the user moves the cursor away" do
    cursorOverLinkTextField.stringValue = 'Mutex#exclusive_unlock'
    controller.webView_mouseDidMoveOverElement_modifierFlags(nil, {}, nil)
    cursorOverLinkTextField.stringValue.should.be.empty
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

describe "WebViewController, when with back/forward items" do
  tests WebViewController
  
  def after_setup
    ib_outlets :webview => OSX::WebView.alloc.init,
               :delegate => stub_everything('Delegate')
    
    @query = 'Binding'
    controller.add_search_back_forward_item(@query)
    @url = OSX::NSURL.URLWithString("kari://search/#{@query}")
  end
  
  it "should create a new WebHistoryItem representing a search query" do
    webview.backForwardList.currentItem.URLString.should == @url.absoluteString
  end
  
  it "should send a delegate message if a special search back/forward item was requested" do
    delegate.expects(:webView_didSelectSearchQuery).with(webview, @query)
    listener = mock('Decision Listener')
    listener.expects(:ignore)
    controller.webView_decidePolicyForNavigationAction_request_frame_decisionListener(nil, nil, OSX::NSURLRequest.requestWithURL(@url), nil, listener)
  end
  
  it "should set the correct BackForward current item if a special search back/forward item was requested" do
    listener = stub_everything('Decision Listener')
    
    assigns(:going_back_or_forward, 0)
    webview.backForwardList.expects(:goBack)
    controller.webView_decidePolicyForNavigationAction_request_frame_decisionListener(nil, nil, OSX::NSURLRequest.requestWithURL(@url), nil, listener)
    
    assigns(:going_back_or_forward, 1)
    webview.backForwardList.expects(:goForward)
    controller.webView_decidePolicyForNavigationAction_request_frame_decisionListener(nil, nil, OSX::NSURLRequest.requestWithURL(@url), nil, listener)
    
    assigns(:going_back_or_forward).should.be nil
  end
  
  xit "should remove blank BackForward items once loaded" do
    assert_no_difference('webview.backForwardList.backListCount') do
      controller.send(:clear_blank_back_forward_items!)
    end
    
    assert_no_difference('webview.backForwardList.backListCount') do
      2.times do
        webview.backForwardList.addItem OSX::WebHistoryItem.alloc.initWithURLString_title_lastVisitedTimeInterval("about:blank", "", 0)
      end
      controller.send(:clear_blank_back_forward_items!)
    end
  end
end