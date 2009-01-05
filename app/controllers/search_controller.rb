class SearchController < Rucola::RCController
  attr_accessor :results
  attr_accessor :delegate
  
  attr_writer :results_array_controller
  attr_writer :results_table_view
  attr_writer :search_field
  
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
      self.results = Manager.instance.search(query_with_partial_matching(query))
      @delegate.searchControllerFinishedSearching
    end
  end
  
  def rowDoubleClicked(tableview)
    @delegate.searchController_selectedFile(self, @results_array_controller.arrangedObjects[tableview.selectedRow].URL)
  end
  
  private
  
  def query_with_partial_matching(query)
    "*#{query.split(' ').join('*')}*"
  end
end