require "osx/cocoa"

class WebViewController < OSX::NSObject
  ib_outlet :webview
  ib_outlet :backForwardButton
  
  attr_accessor :delegate, :port
  attr_reader :doc_title
  
  BASE_URL = 'http://127.0.0.1:10002/'
  
  def awakeFromNib
    @doc_title = "Index"
    @port = 10002
    @webview.frameLoadDelegate = self
    
    OSX::NSNotificationCenter.defaultCenter.objc_send :addObserver, self,
                                                      :selector,    'webViewFinishedLoading:',
                                                      :name,        OSX::WebViewProgressFinishedNotification,
                                                      :object,      nil
  end
  
  def webViewFinishedLoading(aNotification)
    @backForwardButton.setEnabled_forSegment(can_go_back?, BACK_BUTTON)
    @backForwardButton.setEnabled_forSegment(can_go_forward?, FORWARD_BUTTON)
    @delegate.webViewFinishedLoading(aNotification)
  end
  
  def webView_didReceiveTitle_forFrame(sender, title, frame)
    @doc_title = title.to_s
  end
  
  def url
    @webview.mainFrame.dataSource.request.URL.absoluteString
  end
  
  def load_url(url)
    @webview.mainFrame.loadRequest url_request(url)
  end
  
  def url_request(url)
    # substitute a port number in the url with the current port.
    OSX::NSURLRequest.requestWithURL OSX::NSURL.URLWithString(url.sub(/:\d+/, ":#{@port}"))
  end
  
  def can_go_back?
    @webview.canGoBack == 1
  end
  
  def can_go_forward?
    @webview.canGoForward == 1
  end
  
  def can_make_text_smaller?
    @webview.canMakeTextSmaller == 1
  end
  
  def can_make_text_larger?
    @webview.canMakeTextLarger == 1
  end
  
  # helpers
  
  def blank
    load_url 'about:blank'
  end
  
  def home(sender = nil)
    load_url BASE_URL
  end
  ib_action :home
  
  def search(query)
    load_url "#{BASE_URL}search?q=#{query}"
  end
  
  def show(query)
    load_url "#{BASE_URL}show/#{query}"
  end
  
  # Buttons
  
  BACK_BUTTON = 0
  FORWARD_BUTTON = 1
  def goBackOrForward(sender)
    if sender.selectedSegment == BACK_BUTTON
      @webview.goBack(self)
    else
      @webview.goForward(self)
    end
  end
  ib_action :goBackOrForward
  
  def fontLarger(sender)
    @webview.makeTextLarger(self)
  end
  ib_action :fontLarger
  
  def fontSmaller(sender)
    @webview.makeTextSmaller(self)
  end
  ib_action :fontSmaller
  
  def validateMenuItem(item)
    case item.action
    when 'fontLarger:' then can_make_text_larger?
    when 'fontSmaller:' then can_make_text_smaller?
    else
      true
    end
  end
end
