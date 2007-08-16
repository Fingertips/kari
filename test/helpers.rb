$:.unshift(File.expand_path('../lib', File.dirname(__FILE__)))

require 'test/unit'
require 'active_support'

require 'rubygems' rescue LoadError
require 'mocha'