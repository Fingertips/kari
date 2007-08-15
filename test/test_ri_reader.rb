$:.unshift(File.expand_path('../lib', File.dirname(__FILE__)))

require 'test/unit'
require 'kari/ri/reader'

class TestRiReader < Test::Unit::TestCase
  include Kari::RI
  
  def test_initialize
    reader = Reader.new
    assert !reader.paths.empty?
  end
  
  def test_build_index_for
    reader = Reader.new
    reader.write_index_to('index.kari')
  end
end