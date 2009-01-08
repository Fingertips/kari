class WebViewController < Rucola::RCController
  attr_writer :webview
  attr_writer :backForwardButton
  attr_writer :cursorOverLinkTextField
  
  attr_accessor :delegate, :doc_title
  
  def initialize
    @doc_title = ''
  end
  
  def awakeFromNib
    @webview.preferences.tabsToLinks = true
    
    @webview.frameLoadDelegate = self
    @webview.policyDelegate = self
    @webview.UIDelegate = self
    
    NSNotificationCenter.defaultCenter.
      addObserver self,
        selector: 'webViewFinishedLoading:',
            name: WebViewProgressFinishedNotification,
          object: nil
  end
  
  def webViewFinishedLoading(aNotification)
    @backForwardButton.setEnabled_forSegment(can_go_back?, BACK_BUTTON)
    @backForwardButton.setEnabled_forSegment(can_go_forward?, FORWARD_BUTTON)
    @delegate.webViewFinishedLoading(aNotification)
  end
  
  def webView_decidePolicyForNavigationAction_request_frame_decisionListener(webView, information, request, frame, listener)
    if request.URL.absoluteString.to_s =~ /^kari:\/\/search\/(.+)/
      listener.ignore
      
      if @going_back_or_forward
        if @going_back_or_forward == BACK_BUTTON
          @webview.backForwardList.goBack
        else
          @webview.backForwardList.goForward
        end
        @going_back_or_forward = nil
      end
      
      @delegate.webView_didSelectSearchQuery(@webview, $1)
    else
      listener.use
    end
  end
  
  def webView_didReceiveTitle_forFrame(webView, title, frame)
    @doc_title = title.to_s
  end
  
  def webView_mouseDidMoveOverElement_modifierFlags(webView, element, flags)
    if url = element['WebElementLinkURL']
      @cursorOverLinkTextField.stringValue = (url.absoluteString.end_with?('karidoc') ? RubyName.from_karidoc_filename(url.path) : url.absoluteString)
    else
      @cursorOverLinkTextField.stringValue = ''
    end
  end
  
  def bookmarkable?
    not url.nil? and not @webview.hidden? and not (url.to_s =~ /\/app\/assets\/index.html$/)
  end
  
  def url
    @webview.mainFrameURL
  end
  
  # Loads a regular file path like: "/some/path/to/file.karidoc"
  def load_file(file)
    load_url NSURL.fileURLWithPath(file)
  end
  
  # Loads a NSURL in the main frame or creates a NSURL for a string.
  def load_url(url)
    url = NSURL.URLWithString(url) if url.is_a?(String) or url.is_a?(NSCFString)
    @webview.mainFrame.loadRequest NSURLRequest.requestWithURL(url)
  end
  
  def add_search_back_forward_item(query)
    @webview.backForwardList.addItem WebHistoryItem.alloc.initWithURLString("kari://search/#{query}", title: "Kari Search Query Item", lastVisitedTimeInterval: 0)
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
    load_url NSURL.URLWithString('about:blank')
  end
  
  def home!
    load_file File.join(Rucola::RCApp.assets_path, 'index.html')
  end
  
  # Buttons
  
  BACK_BUTTON = 0
  FORWARD_BUTTON = 1
  def goBackOrForward(sender)
    @going_back_or_forward = sender.selectedSegment
    if sender.selectedSegment == BACK_BUTTON
      @webview.goBack(self)
    else
      @webview.goForward(self)
    end
  end
  
  def fontLarger(sender)
    @webview.makeTextLarger(self)
  end
  
  def fontSmaller(sender)
    @webview.makeTextSmaller(self)
  end
  
  def validateMenuItem(item)
    case item.action
    when 'fontLarger:' then can_make_text_larger?
    when 'fontSmaller:' then can_make_text_smaller?
    else
      true
    end
  end
  
  private
  
  def clear_blank_back_forward_items!
    list = @webview.backForwardList
    items = [list.backItem, list.currentItem].compact
    items.each { |item| list.removeItem(item) if item.URLString == 'about:blank' }
  end
end