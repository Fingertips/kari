class ApplicationController
  def webViewFinishedLoading(aNotification)
    @addBookmarkToolbarButton.enabled = @webViewController.bookmarkable?
    self.search_mode = false
  end
  
  def webView_didSelectSearchQuery(webView, query)
    @searchTextField.stringValue = query
    @searchController.search(@searchTextField)
  end
  
  def printWebViewContents(sender)
    print_info = OSX::NSPrintInfo.sharedPrintInfo
    print_info.topMargin = 30
    print_info.leftMargin = 35
    print_info.horizontallyCentered = false
    print_info.verticallyCentered = false
    
    OSX::NSPrintOperation.objc_send(
      :printOperationWithView, @webView.mainFrame.frameView.documentView,
                   :printInfo, print_info
    ).runOperation
  end
end