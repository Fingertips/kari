require File.join(File.dirname(__FILE__), 'helpers')
require 'kari/ri'

class TestRi < Test::Unit::TestCase

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
    Thread.any_instance.stubs(:status).returns(false)
    assert_equal 'ready', Kari::RI.status
    Thread.any_instance.stubs(:status).returns(nil)
    assert_equal 'failed', Kari::RI.status
    Thread.any_instance.stubs(:status).returns('run')
    assert_equal 'rebuilding', Kari::RI.status
    Kari::RI.stubs(:index).returns(Kari::RI::Index.new)
    assert_equal 'building', Kari::RI.status
  end
end
