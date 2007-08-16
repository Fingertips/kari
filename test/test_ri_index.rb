$:.unshift(File.expand_path('../lib', File.dirname(__FILE__)))

require 'test/unit'
require 'kari/ri/index'

class TestRiReader < Test::Unit::TestCase
  include Kari::RI

  def test_initialize
    index = Index.new
    assert !index.paths.empty?
  end

  def test_build
    index = Index.new
    index.write_to('index.bin')
  end
end