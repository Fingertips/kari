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
    # @results_table_view.delegate = self
    @results_table_view.target = self
    @results_table_view.doubleAction = 'rowDoubleClicked:'
    @results_array_controller.sortDescriptors = [OSX::NSSortDescriptor.alloc.initWithKey_ascending('score', false)]
  end
  
  def search(sender)
    query = (sender.is_a?(String) || sender.is_a?(OSX::NSString) ? sender : sender.stringValue)
    unless query.blank?
      @delegate.searchControllerWillStartSearching
      self.results = Manager.instance.search(query)
      @delegate.searchControllerFinishedSearching
    end
  end
  
  def rowDoubleClicked(tableview)
    @delegate.searchController_selectedFile(self, @results_array_controller.arrangedObjects[tableview.selectedRow].URL)
  end
end