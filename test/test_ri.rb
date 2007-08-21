require File.join(File.dirname(__FILE__), 'helpers')
require 'kari/ri'

class TestRi < Test::Unit::TestCase

  def setup
    Logger.any_instance.stubs(:debug).returns(nil)
  end

  def test_search
    matches = Kari::RI.search("point")
    assert_equal 1, matches.length
    assert matches.first.is_a?(Kari::RI::Entry)
    assert_equal "Geometry::Point", matches.first.full_name
  end

  def test_quick_search
    matches = Kari::RI.quick_search("point")
    assert_equal 1, matches.length
    assert matches.first.is_a?(Hash)
    assert_equal "Geometry::Point", matches.first[:full_name]
  end

  def test_get
    entry = Kari::RI.get('Geometry::Square')
    assert entry.class?
    assert_not_nil entry.full_name
    assert_not_nil entry.name
  end

  def test_status
    Kari::RI::Index.expects(:rebuild).returns(nil)
    load 'kari/ri.rb'
    assert_equal 'indexing', Kari::RI.status
    Kari::RI::Index.expects(:rebuild).returns(Kari::RI::Index.new)
    load 'kari/ri.rb'
    assert_equal 'ready', Kari::RI.status
    Kari::RI::Index.expects(:rebuild).returns("Something else")
    load 'kari/ri.rb'
    assert_equal 'indexing failed', Kari::RI.status
  end
end
