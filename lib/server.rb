#!/usr/bin/env ruby

DIR_LIB = File.expand_path(File.dirname(__FILE__))
$:.unshift(DIR_LIB)

require 'ostruct'
require 'camping'
require 'camping/server'

require 'optparse'

conf = OpenStruct.new(:host => '0.0.0.0', :port => 9999)
conf.db = '/dev/null'
conf.rc = '/dev/null'

opts = OptionParser.new do |opts|
  opts.banner = "Usage: #{File.basename($0)} [options]"
  opts.separator ""
  opts.separator "Options:"

  opts.on("-h", "--host HOSTNAME", "Host for web server to bind to (default is all IPs)") { |conf.host| }
  opts.on("-p", "--port NUM", "Port for web server (defaults to #{conf.port})") { |conf.port| }
  opts.on_tail("-?", "--help", "Show this message") do
      puts opts
      exit
  end
end
opts.parse! ARGV

# Check that mongrel exists
unless conf.server 
  begin
    require 'rubygems' rescue LoadError
    require 'mongrel'
    require 'mongrel/camping'
    conf.server = :mongrel
  rescue LoadError 
    conf.server = :webrick
  end
end

require 'camping/server/' + conf.server.to_s

server = eval("Camping::Server::#{conf.server.to_s.capitalize}.new(conf, [File.join(DIR_LIB, 'kari.rb')])")
server.start
