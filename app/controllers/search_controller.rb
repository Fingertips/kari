class SearchController < Rucola::RCController
  kvc_accessor :metadata
  attr_accessor :delegate
  
  ib_outlets :find_by_name, :find_by_full_name, :find_by_path, :find_by_type
  ib_outlets :metadata_array_controller, :results_table_view
  
  notify :query_did_finish, :when => OSX::NSMetadataQueryDidFinishGatheringNotification
  
  def after_init
    @metadata = OSX::NSMetadataQuery.alloc.init
    @metadata.sortDescriptors = [OSX::NSSortDescriptor.alloc.initWithKey_ascending(NAME, true)]
  end
  
  def awakeFromNib
    @results_table_view.target = self
    @results_table_view.doubleAction = 'rowDoubleClicked:'
  end
  
  def rowDoubleClicked(tableview)
    temp_disable_updates do
      @delegate.searchControllerSelectedURL(
        OSX::NSURL.fileURLWithPath(
          @metadata_array_controller.arrangedObjects[tableview.clickedRow].valueForAttribute('kMDItemPath')
        )
      )
    end
  end
  
  def search(sender)
    @search_string = sender.stringValue if sender.is_a?(OSX::NSSearchField)
    start_query! unless @search_string.nil?
  end
  
  def query_did_finish(notification)
    # p notification
    #p @metadata.resultCount
  end
  
  private
  
  def temp_disable_updates
    @metadata.disableUpdates
    yield
    @metadata.enableUpdates
  end
  
  def start_query!
    @metadata.predicate = OSX::NSPredicate.predicateWithFormat(query)
    @metadata.startQuery
  rescue OSX::OCException => e
    puts "Error while start query: #{e.message}"
  end
  
  def query
    if (attrs = attrs_to_find_by)
      result = "(#{attrs.map { |attr| "(#{ attr } LIKE[wcd] '*#{ @search_string }*')" }.join(" || ")})"
      unless @find_by_type.selectedItem.title == "all"
        types = (@find_by_type.selectedItem.title == 'methods' ? ['ClassMethod', 'Method'] : ['Class', 'Module'])
        result = "(#{result} && #{types.map { |type| "(#{TYPE} == '#{type}')" }.join(' || ')})"
      end
      puts "Compiled query: #{result}"
      result
    end
  end
  
  def attrs_to_find_by
    ATTRS.reject {|k,v| instance_variable_get("@find_by_#{k}").state == OSX::NSOffState }.values
  end
  
  TYPE = 'com_fngtps_kari_karidoc_type'
  NAME = 'com_fngtps_kari_karidoc_name'
  PATH = 'com_fngtps_kari_karidoc_path'
  FULL_NAME = 'com_fngtps_kari_karidoc_fullName'
  ALL = [TYPE, NAME, PATH, FULL_NAME]
  ATTRS = { :name => NAME, :full_name => FULL_NAME, :path => PATH }
end