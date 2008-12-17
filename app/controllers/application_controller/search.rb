class ApplicationController < Rucola::RCController
  def searchControllerWillStartSearching
    @addBookmarkToolbarButton.enabled = false
    @searchProgressIndicator.startAnimation(self)
    
    @webView.hidden = true
    @resultsScrollView.hidden = false
  end
  
  def searchControllerFinishedSearching
    @searchProgressIndicator.stopAnimation(self)
  end
  
  def searchController_selectedFile(sender, url)
    @webViewController.load_url(url)
    @webViewController.add_search_back_forward_item(@searchTextField.stringValue)
    @webView.hidden = false
    @resultsScrollView.hidden = true
    @window.makeFirstResponder(@webView)
  end
end