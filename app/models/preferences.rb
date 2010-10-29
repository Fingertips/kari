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
    preferences['interface.class_browser_visible'] = true
    preferences['interface.class_browser_height']  = 138
    preferences['search.index_type']               = Preferences::Search::TYPES[:path]
    preferences['search.scope']                    = Preferences::Search::SCOPES[:all]
  end
  
  register_default_values!
end