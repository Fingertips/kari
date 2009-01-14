# TMP MacRuby workaround: http://www.macruby.org/trac/ticket/207
module Kernel
  def copy(*args, &block)
    true
  end
end


$: << "/Users/eloy/code/MacRuby/rucola/lib"
require File.expand_path('../config/boot', __FILE__)
require 'rucola/rake'