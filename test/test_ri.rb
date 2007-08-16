$:.unshift(File.expand_path('../lib', File.dirname(__FILE__)))

require 'rubygems' rescue LoadError

require 'test/unit'
require 'mocha'

require 'kari/ri'
require 'active_support'

class TestRiIndex < Test::Unit::TestCase
  include Kari::RI

  def setup
    Index.stubs(:default_path).returns(File.expand_path('fixtures/index.marshal', File.dirname(__FILE__)))
  end

  def test_search
    matches = search('point')
    p matches.first.definition
  end
end