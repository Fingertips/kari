require File.join(File.dirname(__FILE__), 'helpers')
require 'kari/ri/entry'
require 'kari/ri/index'

class TestRiEntry < Test::Unit::TestCase

  def setup
    @index = Kari::RI::Index.load
  end

  def test_method_missing_should_allow_access_to_definition
    entry = Kari::RI::Entry.new(@index.get("Geometry::Point"), @index)
    assert_equal "Point", entry.name
    assert entry.comment
  end

  def test_should_return_path
    {
      "Geometry::Point" => "Geometry",
      "Geometry::Point::new" => "Geometry::Point",
      "Geometry::Square::rotate" => "Geometry::Square",
      "Geometry" => ""
    }.each do |full_name, expected|
      assert_equal expected, Kari::RI::Entry.new({:full_name => full_name}, nil).path
    end
  end

  %w(instance_methods class_methods includes).each do |t|
    define_method "test_should_return_#{t}" do
      interest = "Geometry::Square"
      entry = Kari::RI::Entry.new(@index.get(interest), @index)
      entry.send(t).each do |method|
        assert method.is_a?(Kari::RI::Entry)
        assert method.full_name.index("::")
        assert_not_nil method.name
      end
    end
  end
end