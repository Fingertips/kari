require File.join(File.dirname(__FILE__), 'helpers')
require 'kari/ri/entry'
require 'kari/ri/index'

class TestRiEntry < Test::Unit::TestCase
  include Kari::RI

  def setup
    Index.stubs(:default_path).returns(File.expand_path("fixtures/index.marshal", File.dirname(__FILE__)))
    @index = Index.load
  end

  def test_method_missing_should_allow_access_to_definition
    entry = Entry.new(@index.get("Geometry::Point"), @index)
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
      assert_equal expected, Entry.new({:full_name => full_name}, nil).path
    end
  end

  %w(instance_methods class_methods).each do |t|
    define_method "test_should_return_#{t}" do
      interest = "Geometry::Square"
      entry = Entry.new(@index.get(interest), @index)
      entry.send(t).each do |method|
        assert method.is_a?(Entry)
        assert method.full_name.starts_with?(interest)
      end
    end
  end
end