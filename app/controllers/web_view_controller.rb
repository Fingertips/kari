class WebViewController < Rucola::RCController
  ib_outlet :webview
  ib_outlet :backForwardButton
  
  attr_accessor :delegate, :doc_title
  
  def after_init
    @doc_title = ''
  end
  
  def awakeFromNib
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
  
  def webView_didReceiveTitle_forFrame(webView, title, frame)
    @doc_title = title.to_s
  end
  
  def bookmarkable?
    not url.nil? and not @webview.hidden? and not (url.to_s =~ /\/app\/assets\/index.html$/)
  end
  
  def url
    @webview.mainFrameURL
  end
  
  # Loads a regular file path like: "/some/path/to/file.karidoc"
  def load_file(file)
    load_url OSX::NSURL.fileURLWithPath(file)
  end
  
  # Loads a NSURL in the main frame or creates a NSURL for a string.
  def load_url(url)
    url = OSX::NSURL.URLWithString(url) if url.is_a?(String) or url.is_a?(OSX::NSCFString)
    @webview.mainFrame.loadRequest OSX::NSURLRequest.requestWithURL(url)
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
  
  def blank!
    # FIXME: blank should never appear in the BackForwardList.
    load_url OSX::NSURL.URLWithString('about:blank')
  end
  
  def home!
    load_file File.join(Rucola::RCApp.assets_path, 'index.html')
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