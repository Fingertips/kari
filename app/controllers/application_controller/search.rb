class ApplicationController
  def searchControllerWillStartSearching
    self.search_mode = true
    @addBookmarkToolbarButton.enabled = false
    @searchProgressIndicator.startAnimation(self)
  end
  
  def searchControllerFinishedSearching
    @searchProgressIndicator.stopAnimation(self)
  end
  
  def searchController_selectedFile(sender, url)
    @webViewController.load_url(url)
    @webViewController.add_search_back_forward_item(@searchTextField.stringValue)
    self.search_mode = false
    @window.makeFirstResponder(@webView)
  end
end