require 'singleton'

class UserPreferences
  include Singleton
  
  def initialize
    reset!
  end
  
  def registerDefaults(defaults)
    @defaults = defaults
  end
  
  def [](key)
    @defaults.merge(@preferences)[key]
  end
  alias_method :objectForKey, :[]
  
  def []=(key, value)
    @preferences[key] = value
  end
  alias_method :setObjectForKey, :[]=
  
  def synchronize
  end
  
  def reset!
    @preferences = {}
    @defaults = {}
  end
end

# We don't want test ruining our preferences
class NSUserDefaults < NSObject
  def self.standardUserDefaults
    UserPreferences.instance
  end
end