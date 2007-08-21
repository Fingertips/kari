require File.join(File.dirname(__FILE__), 'helpers')
require 'kari/ri'

class TestRi < Test::Unit::TestCase
  include Kari::RI

  def setup
    Logger.any_instance.stubs(:debug).returns(nil)
  end

  def test_search
    matches = search("point")
    assert_equal 1, matches.length
    assert matches.first.is_a?(Entry)
    assert_equal "Geometry::Point", matches.first.full_name
  end

  def test_quick_search
    matches = quick_search("point")
    assert_equal 1, matches.length
    assert matches.first.is_a?(Hash)
    assert_equal "Geometry::Point", matches.first[:full_name]
  end

  def test_get
    entry = get('Geometry::Square')
    assert entry.class?
    assert_not_nil entry.full_name
    assert_not_nil entry.name
  end

  def test_status
    Kari::RI::Index.expects(:rebuild).returns(nil)
    load 'kari/ri.rb'
    assert_equal 'indexing', status
    Kari::RI::Index.expects(:rebuild).returns(Kari::RI::Index.new)
    load 'kari/ri.rb'
    assert_equal 'ready', status
    Kari::RI::Index.expects(:rebuild).returns("Something else")
    load 'kari/ri.rb'
    assert_equal 'indexing failed', status
  end
end
