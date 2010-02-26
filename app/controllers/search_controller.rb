class SearchController < Rucola::RCController
  kvc_accessor :results
  attr_accessor :delegate
  
  ib_outlets :results_array_controller,
    :results_table_view,
    :search_field,
    :class_tree_controller
  
  def after_init
    @results = OSX::NSMutableArray.alloc.init
  end
  
  def awakeFromNib
    @search_field.keyDelegate = @results_table_view
    @results_table_view.target = self
    @results_array_controller.sortDescriptors = [OSX::NSSortDescriptor.alloc.initWithKey_ascending('score', false)]
  end
  
  def search(sender)
    @delegate.searchControllerWillStartSearching
    @results_array_controller.search(sender)
    @delegate.searchControllerFinishedSearching
    @results_table_view.scrollToRow(0)
  end
  
  def rowDoubleClicked(tableview)
    scoredKariName = @results_array_controller.arrangedObjects[tableview.selectedRow]
    @delegate.searchController_selectedFile(self, scoredKariName.karidocFilename)
    @class_tree_controller.setSelectionRubyName(scoredKariName.name)
  end
  
  def setResultsForDescriptions(descriptions)
    self.results = descriptions.map do |name, definitions|
      OSX::ScoredRubyName.alloc.initWithName_karidocFilename_query(
        name,
        RubyName.karidoc_filename(Manager.current_filepath, name),
        nil
      )
    end
  end
end