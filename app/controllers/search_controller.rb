class SearchController < Rucola::RCController
  kvc_accessor :results
  attr_accessor :delegate
  
  ib_outlets :results_array_controller
  ib_outlet :results_table_view
  ib_outlet :search_field
  
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
    @results_table_view.scrollToRow(0, false)
  end
  
  def rowDoubleClicked(tableview)
    @delegate.searchController_selectedFile(self, @results_array_controller.arrangedObjects[tableview.selectedRow].karidocFilename)
  end
end