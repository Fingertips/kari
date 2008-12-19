class Preferences
  class Interface < Namespace
    defaults_accessor :class_browser_visible, false
    defaults_accessor :class_browser_height, 135
  end
  
  register_default_values!
end