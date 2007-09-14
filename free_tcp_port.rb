require "socket"

module FreeTCPPort
  
  IANA_FILE = '/etc/services'
  
  def self.get_iana_unassigned_ports(options = {})
    options[:start_from] ||= (options[:lower_than_1024] ? 0 : 1025)
    
    ports = []
    reached_start = false
    File.read(IANA_FILE).each_line do |line|
      if line =~ /([\dtcudp\/-]+)\s+Unassigned\s*$/
        match = $1
        
        if match.include? '-'
          port_start, port_end = match.split('-')
          match = port_start.to_i..port_end.to_i
        else
          # transform to a range, because this makes the code a lot easier to read.
          match = match.to_i..match.to_i
        end

        next unless reached_start || match.first >= options[:start_from] || match.last >= options[:start_from]
        reached_start = true

        if match.first >= options[:start_from]
          ports += match.to_a
        else
          ports += (options[:start_from]..match.last).to_a
        end
      end
    end
    ports.uniq
  end
  
  def self.find(options = {})
    ports = FreeTCPPort.get_iana_unassigned_ports(options)
    ports.each do |port|
      begin
        TCPSocket.new('localhost', port)
      rescue Errno::ECONNREFUSED
        # connection refused, so this must be a free port
        return port
      end
    end
    nil
  end
end
