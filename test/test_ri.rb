require File.join(File.dirname(__FILE__), 'helpers')
require 'kari/ri'

class TestRi < Test::Unit::TestCase
  include Kari::RI

  def setup
    Index.stubs(:default_path).returns(File.expand_path('fixtures/index.marshal', File.dirname(__FILE__)))
  end

  def test_search
    matches = search('point')
    p matches.first.definition
  end
end