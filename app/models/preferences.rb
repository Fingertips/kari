class Preferences
  class General < Namespace
    BOOKMARKS = %w{ Object String Array Hash Numeric }.map do |title|
      url = OSX::NSURL.fileURLWithPath(File.join(Rucola::RCApp.application_support_path, 'Karidoc', "#{title}.karidoc"))
      { 'title' => title, 'url' => url.absoluteString }
    end
    p BOOKMARKS
    defaults_accessor :bookmarks, BOOKMARKS
    defaults_accessor :last_fs_event_id
  end
  
  class Interface < Namespace
    defaults_accessor :class_browser_visible, false
    defaults_accessor :class_browser_height,  138
  end
  
  class Search < Namespace
    TYPES = { :path => 0, :content => 1 }
    SCOPES = { :all => 0, :class => 1, :method => 2 }
    
    defaults_accessor :index_type, TYPES[:path]
    defaults_accessor :scope,      SCOPES[:all]
  end
  
  register_default_values!
end