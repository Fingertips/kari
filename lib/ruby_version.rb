module Kernel
  private
  
  def on_macruby?
    defined?(MACRUBY_VERSION)
  end
end