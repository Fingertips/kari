class SearchController
  attr_accessor :results
  attr_accessor :delegate
  
  attr_writer :results_array_controller
  attr_writer :results_table_view
  attr_writer :class_tree_controller
  
  def init
    if super
      @results = NSMutableArray.alloc.init
      self
    end
  end
  
  def awakeFromNib
    @results_table_view.target = self
    @results_array_controller.sortDescriptors = [NSSortDescriptor.alloc.initWithKey('score', ascending: false)]
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
      ScoredRubyName.alloc.initWithName(name,
        karidocFilename: RubyName.karidoc_filename(Manager.current_filepath, name),
                  query: nil
      )
    end
  end
end