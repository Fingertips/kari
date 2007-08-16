$:.unshift(File.expand_path('../lib', File.dirname(__FILE__)))

require 'rubygems' rescue LoadError

require 'test/unit'
require 'fileutils'
require 'tmpdir'
require 'mocha'

require 'kari/ri/index'

class TestRiIndex < Test::Unit::TestCase
  include Kari::RI

  def setup
    @ri_fixture_path = File.expand_path('fixtures/ri', File.dirname(__FILE__))
    @tmpdir = File.join(Dir.tmpdir, 'kari')
    FileUtils.mkdir_p(@tmpdir)
  end

  def teardown
    FileUtils.rm_rf(@tmpdir)
  end

  def test_build
    RI::Paths.expects(:path).returns(@ri_fixture_path)
    Index.any_instance.expects(:write_to).returns(true)
    assert_nothing_raised { Index.build }
  end
end