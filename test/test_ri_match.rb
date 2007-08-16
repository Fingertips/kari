$:.unshift(File.expand_path('../lib', File.dirname(__FILE__)))

require 'rubygems' rescue LoadError

require 'test/unit'
require 'mocha'

require 'kari/ri/match'
require 'kari/ri/index'
require 'active_support'

class TestRiIndex < Test::Unit::TestCase
  include Kari::RI

  def setup
    Index.stubs(:default_path).returns(File.expand_path("fixtures/index.marshal", File.dirname(__FILE__)))
    @index = Index.load
  end

  def test_method_missing_should_allow_access_to_definition
    match = Match.new(@index.get("Geometry::Point"), @index)
    assert_equal "Point", match.name
    assert match.comment
  end

  def test_should_return_path
    {
      "Geometry::Point" => "Geometry",
      "Geometry::Point::new" => "Geometry::Point",
      "Geometry::Square::rotate" => "Geometry::Square",
      "Geometry" => ""
    }.each do |full_name, expected|
      assert_equal expected, Match.new({:full_name => full_name}, nil).path
    end
  end

  %w(instance_methods class_methods).each do |t|
    define_method "test_should_return_#{t}" do
      interest = "Geometry::Square"
      match = Match.new(@index.get(interest), @index)
      match.send(t).each do |method|
        assert method.is_a?(Match)
        assert method.full_name.starts_with?(interest)
      end
    end
  end
end