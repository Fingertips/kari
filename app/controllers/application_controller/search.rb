class ApplicationController < Rucola::RCController
  def setup_search!
    @searchController.setResultsForDescriptions(Manager.instance.descriptions)
  end
  
  def searchControllerWillStartSearching
    self.search_mode = true
    @searchProgressIndicator.startAnimation(self)
  end
  
  def searchControllerFinishedSearching
    @searchProgressIndicator.stopAnimation(self)
  end
  
  def searchController_selectedFile(sender, karidocFilename)
    @webViewController.load_file(karidocFilename)
    @webViewController.add_search_back_forward_item(@searchTextField.stringValue)
    self.search_mode = false
    @window.makeFirstResponder(@webView)
  end
end