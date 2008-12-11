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
  
  # def search(sender)
  #   @search_string = sender.stringValue if sender.is_a?(OSX::NSSearchField)
  #   start_query! unless @search_string.nil? or @search_string.empty?
  # end
  # 
  # def updating?
  #   @updating
  # end
  # 
  # notify_on OSX::NSMetadataQueryDidFinishGatheringNotification do |notification|
  #   will_change_metadata do
  #     @metadata.removeAllObjects
  #     @metadata.addObjectsFromArray(@spotlight.results) unless @spotlight.resultCount.zero?
  #   end
  # end
  # 
  # private
  # 
  # def will_change_metadata
  #   @spotlight.disableUpdates
  #   willChangeValueForKey('metadata')
  #   @updating = true
  #   
  #   yield
  #   
  #   didChangeValueForKey('metadata')
  #   @spotlight.enableUpdates
  #   
  #   @updating = false
  #   @delegate.searchControllerFinishedSearching
  # end
  # 
  # def start_query!
  #   @delegate.searchControllerWillStartSearching
  #   @spotlight.predicate = OSX::NSPredicate.predicateWithFormat(query)
  #   @spotlight.startQuery
  # rescue OSX::OCException => e
  #   log.error "Error while starting query: #{e.message}"
  # end
  # 
  # def query
  #   chars = @search_string.scan(/./)
  #   query = "((#{FULL_NAME} LIKE[wcd] '#{ @search_string }*') || (#{FULL_NAME} LIKE[c] '*#{ chars.join('*') }*'))"
  #   
  #   log.debug "Compiled query: #{query}\n"
  #   query
  # end
  # 
  # TYPE = 'com_fngtps_kari_karidoc_type'
  # NAME = 'com_fngtps_kari_karidoc_name'
  # PATH = 'com_fngtps_kari_karidoc_path'
  # FULL_NAME = 'com_fngtps_kari_karidoc_fullName'
  # ALL = [TYPE, NAME, PATH, FULL_NAME]
  # ATTRS = { :name => NAME, :full_name => FULL_NAME, :path => PATH }
end