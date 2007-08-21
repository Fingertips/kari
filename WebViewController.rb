require "osx/cocoa"

class WebViewController < OSX::NSObject
  ib_outlet :webview
  attr_accessor :delegate
  attr_reader :doc_title
  
  def awakeFromNib
    @doc_title = "Kari - Search for Ruby documentation"
    
    @webview.frameLoadDelegate = self
    
    OSX::NSNotificationCenter.defaultCenter.objc_send :addObserver, self,
                                                      :selector,    'webViewFinishedLoading:',
                                                      :name,        OSX::WebViewProgressFinishedNotification,
                                                      :object,      nil
  end
  
  def webViewFinishedLoading(aNotification)
    @delegate.webViewFinishedLoading(aNotification)
  end
  
  def webView_didReceiveTitle_forFrame(sender, title, frame)
    @doc_title = "Kari - #{title}"
  end
  
  def url
    @url
  end
  
  def load_url(url)
    @webview.mainFrame.loadRequest url_request(url)
  end
  
  def url_request(url)
    OSX::NSURLRequest.requestWithURL OSX::NSURL.URLWithString(url)
  end
  
  def can_go_back?
    @webview.canGoBack == 1
  end
  
  def can_go_forward?
    @webview.canGoForward == 1
  end
  
end
