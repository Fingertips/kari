class ApplicationController < Rucola::RCController
  def setup_search!
    @searchController.results = Manager.instance.descriptions.map do |name, definitions|
      OSX::ScoredRubyName.alloc.initWithName_karidocFilename_query(
        name,
        RubyName.karidoc_filename(Manager.current_filepath, name),
        nil
      )
    end
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