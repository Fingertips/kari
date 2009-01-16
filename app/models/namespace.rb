class Namespace
  def initialize(namespace)
    @namespace = {}
    namespace.each { |k,v| @namespace[k.to_s] = v }
  end
  
  def assign(key, value)
    @namespace[key.to_s] = value
  end
  
  def method_missing(method, *a)
    if respond_to?(method)
      @namespace[method.to_s]
    else
      super
    end
  end
  
  def respond_to?(method)
    super or @namespace.has_key?(method.to_s)
  end
  
  # MacRuby bug: http://www.macruby.org/trac/ticket/208
  #public :binding
  alias_method :__binding, :binding
  def binding
    __binding
  end
end