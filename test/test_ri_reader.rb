$:.unshift(File.expand_path('../lib', File.dirname(__FILE__)))

require 'test/unit'
require 'kari/ri/reader'

class TestRiReader < Test::Unit::TestCase
  include Kari::RI

  def test_truth
    assert true
  end
end