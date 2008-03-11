class SearchController < Rucola::RCController
  kvc_accessor :metadata
  attr_accessor :delegate
  
  ib_outlets :find_by_name, :find_by_full_name, :find_by_path, :find_by_type
  ib_outlets :metadata_array_controller, :results_table_view
  ib_outlet :search_field
  
  notify :query_did_finish, :when => OSX::NSMetadataQueryDidFinishGatheringNotification
  
  def after_init
    @spotlight = OSX::NSMetadataQuery.alloc.init
    @spotlight.sortDescriptors = [OSX::NSSortDescriptor.alloc.initWithKey_ascending(FULL_NAME, true)]
    @metadata = OSX::NSMutableArray.alloc.init
    @updating = false
  end
  
  def awakeFromNib
    @search_field.keyDelegate = @results_table_view
    
    @results_table_view.delegate = self
    @results_table_view.target = self
    @results_table_view.doubleAction = 'rowDoubleClicked:'
  end
  
  def rowDoubleClicked(tableview)
    @delegate.searchController_selectedFile(self, @metadata_array_controller.arrangedObjects[tableview.selectedRow].valueForAttribute('kMDItemPath'))
  end
  
  def search(sender)
    @search_string = sender.stringValue if sender.is_a?(OSX::NSSearchField)
    start_query! unless @search_string.nil? or @search_string.empty?
  end
  
  def updating?
    @updating
  end
  
  def query_did_finish(notification)
    will_change_metadata do
      @metadata.removeAllObjects
      @metadata.addObjectsFromArray(@spotlight.results) unless @spotlight.resultCount.zero?
    end
  end
  
  private
  
  def will_change_metadata
    @spotlight.disableUpdates
    willChangeValueForKey('metadata')
    @updating = true
    
    yield
    
    didChangeValueForKey('metadata')
    @spotlight.enableUpdates
    
    #@results_table_view.deselectAll(self)
    @updating = false
    @delegate.searchControllerFinishedSearching
  end
  
  def start_query!
    @delegate.searchControllerWillStartSearching
    @spotlight.predicate = OSX::NSPredicate.predicateWithFormat(query)
    @spotlight.startQuery
  rescue OSX::OCException => e
    puts "Error while start query: #{e.message}"
  end
  
  def query
    chars = @search_string.scan(/./)
    query = "((#{FULL_NAME} LIKE[wcd] '#{ @search_string }*') || (#{FULL_NAME} LIKE[c] '*#{ chars.join('*') }*'))"
    
    log.debug "Compiled query: #{query}\n"
    query
  end
  
  TYPE = 'com_fngtps_kari_karidoc_type'
  NAME = 'com_fngtps_kari_karidoc_name'
  PATH = 'com_fngtps_kari_karidoc_path'
  FULL_NAME = 'com_fngtps_kari_karidoc_fullName'
  ALL = [TYPE, NAME, PATH, FULL_NAME]
  ATTRS = { :name => NAME, :full_name => FULL_NAME, :path => PATH }
end