require File.join(File.dirname(__FILE__), 'helpers')

require 'fileutils'
require 'tmpdir'

require 'kari/ri/index'

class TestRiIndex < Test::Unit::TestCase
  include Kari::RI

  def setup
    # Create a disposable output directory
    @tmpdir = File.join(Dir.tmpdir, 'kari')
    FileUtils.mkdir_p(@tmpdir)
    # Point the indexer to our ri fixtures path
    @fixture_path = File.expand_path('fixtures', File.dirname(__FILE__))
    @ri_fixture_path = File.expand_path('fixtures/ri', File.dirname(__FILE__))
    RI::Paths.stubs(:path).returns(@ri_fixture_path)
    # Turn off the logger debugging for test
    Logger.any_instance.stubs(:debug).returns(nil)
  end

  def teardown
    # Remove the disposable output directory
    FileUtils.rm_rf(@tmpdir)
  end

  def test_should_build_index_to_file
    Index.any_instance.expects(:write_to).returns(true)
    assert_nothing_raised { Index.rebuild(:from => 10.years.ago) }
  end

  def test_should_build_index
    index = Index.new
    assert_nothing_raised { index.rebuild([@ri_fixture_path], :from => 10.years.ago) }
    assert_not_nil index.data
  end

  def test_should_build_a_usable_index
    index = Index.build_for(@ri_fixture_path)
    assert !index.empty?
    assert_equal %w(Defaults Geometry Introspection Point Square inspect new rotate), index.keys.sort
    assert_equal 1, index["Point"].length
    assert_equal 2, index["new"].length
    assert index["new"].first.has_key?(:full_name)
    assert index["new"].first.has_key?(:definition_file)
  end

  def test_should_merge_updated_index
    index = Index.rebuild
    assert_equal 1, index["Point"].length
    index.rebuild([ENV["KARI_RI_PATH"]], :from => 10.years.ago)
    assert_equal 1, index["Point"].length
  end

  def test_should_write_to_marshalled_file
    index = Index.new
    filename = File.join(@tmpdir, 'index.marshal')
    index.write_to(filename)
    assert File.exist?(filename)
  end

  def test_should_read_from_marshalled_file
    index = Index.new
    data = "I was read"
    filename = File.join(@tmpdir, 'index.marshal')
    File.expects(:read).with(filename).returns(Marshal.dump(data))

    index.read_from(filename)
    assert_equal data, index.data
  end

  def test_should_find_results_in_index
    index = Index.load
    
    results = index.find('new')
    assert_equal ["Geometry::Point::new", "Geometry::Square::new"], results.map { |r| r[:full_name] }.sort
    results = index.find('new point')
    assert_equal ["Geometry::Point", "Geometry::Point::new", "Geometry::Square::new"], results.map { |r| r[:full_name] }.sort
    results = index.find('def')
    assert_equal ["Geometry::Defaults"], results.map { |r| r[:full_name] }.sort
    results = index['def']
    assert_equal ["Geometry::Defaults"], results.map { |r| r[:full_name] }.sort
    results = index[/^Defau...$/]
    assert_equal ["Geometry::Defaults"], results.map { |r| r[:full_name] }.sort
    results = index.find('unknown')
    assert_equal 0, results.length
    results = index.find(nil)
    assert_equal 0, results.length
    results = index.find('')
    assert_equal 0, results.length
  end

  def test_should_get_index_for_full_name
    index = Index.load

    %w(Geometry::Defaults Geometry::Point::new Geometry::Square#rotate).each do |full_name|
      entry = index.get(full_name)
      assert_equal full_name, entry[:full_name]
    end
    assert_nil index.get("unknown")
    assert_nil index.get("")
    assert_nil index.get(nil)
  end

  def test_should_find_class_in_path_in_namespace
    index = Index.load

    {
      ["Geometry::Point::ClassMethods", "Defaults"] => "Geometry::Defaults",
      ["Geometry::Point", "Defaults"] => "Geometry::Defaults",
      ["Geometry::Point", "Unknown"] => nil,
      ["Unknown::Point::ClassMethods", "Defaults"] => nil,
    }.each do |(namespace, needle), expected|
      result = index.find_class_in_path(namespace, needle)
      expected.nil? ? assert_nil(result) : assert_equal(expected, result[:full_name])
    end
  end

  def test_default_index_path
    assert Index.default_index_path.starts_with?(File.expand_path(File.dirname(__FILE__)))
  end

  def test_prepare_query
    index = Index.new
    {
      'point' => "point",
      'my point' => "my|point",
      'my / point' => "my|/|point"
    }.each do |term, expected|
      assert_equal(Regexp.new(expected, Regexp::IGNORECASE, 'u'), index.send(:prepare_query, term))
    end
  end
end