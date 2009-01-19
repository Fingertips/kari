class Namespace
  def initialize(namespace)
    @namespace = {}
    namespace.each { |k,v| assign(k,v) }
  end
  
  # Assigns a value to the namespace and defines a method on the instance's
  # singleton for the given +key+.
  def assign(key, value)
    @namespace[key.to_s] = value
    eval "def #{key}; @namespace['#{key}'] end"
  end
  
  # MacRuby bug: http://www.macruby.org/trac/ticket/208
  #public :binding
  alias_method :__binding, :binding
  def binding
    __binding
  end
end