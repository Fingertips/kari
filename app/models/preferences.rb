module Preferences
  module Search
    TYPES  = {
      :path => 0,
      :content => 1
    }
    SCOPES = {
      :all => 0,
      :class => 1,
      :method => 2
    }
  end
  
  def self.register_default_values!
    preferences['Preferences.Interface.class_browser_visible'] = true
    preferences['Preferences.Interface.class_browser_height']  = 138
    preferences['Preferences.Search.index_type']               = Preferences::Search::TYPES[:path]
    preferences['Preferences.Search.scope']                    = Preferences::Search::SCOPES[:all]
  end
  
  register_default_values!
end