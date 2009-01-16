require 'plugins/rubycocoa-prefs/lib/abstract_preferences'

class Preferences
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