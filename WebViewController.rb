require "osx/cocoa"

class WebViewController < OSX::NSObject
  ib_outlet :webview
  attr_accessor :delegate
  attr_reader :doc_title
  
  BASE_URL = 'http://127.0.0.1:9999/'
  
  def awakeFromNib
    @doc_title = "Index"
    
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
    @doc_title = title.to_s
  end
  
  def url
    @webview.mainFrame.dataSource.request.URL.absoluteString
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
  
  # helpers
  
  def home
    self.load_url BASE_URL
  end
  
  def search(query)
    self.load_url "#{BASE_URL}search?q=#{query}"
  end
  
  def show(query)
    self.load_url "#{BASE_URL}show/#{query}"
  end
  
end
