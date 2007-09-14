require "test/unit"

require "../free_tcp_port"
require "socket"

FreeTCPPort::IANA_FILE = 'test_services'

class TestFreeTCPPort < Test::Unit::TestCase
  def setup
    @lower_ports = [4, 6, 1023, 1024]
    @high_ports = [1028, 1029, 1030]
  end
  
  def test_get_unassigned_ports_default
    ports = FreeTCPPort.get_iana_unassigned_ports
    assert_kind_of(Array, ports)
    ports.each { |port| assert_kind_of(Numeric, port) }
    assert_equal(@high_ports, ports)
  end
  
  def test_get_unassigned_ports_with_lower_than_1024
    ports = FreeTCPPort.get_iana_unassigned_ports :lower_than_1024 => true
    assert_equal(@lower_ports + @high_ports, ports)
  end
  
  def test_get_unassigned_ports_not_lower_than_1024
    ports = FreeTCPPort.get_iana_unassigned_ports :lower_than_1024 => false
    assert_equal(@high_ports, ports)
  end
  
  def test_get_unassigned_ports_start_from
    ports = FreeTCPPort.get_iana_unassigned_ports :start_from => 1029
    assert_equal((@high_ports - [1028]), ports)
  end
  
  def test_find_free_port_default
    assert_equal 1028, FreeTCPPort.find
  end
  
  def test_find_free_port_lower_than_1024
    assert_equal 4, FreeTCPPort.find(:lower_than_1024 => true)
  end
  
  def test_find_free_port_start_from
    not_free_port1 = TCPServer.new(1028)
    not_free_port2 = TCPServer.new(1029)
    assert_equal 1030, FreeTCPPort.find(:start_from => 1028)
  end
end