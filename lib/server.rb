#!/usr/bin/env ruby

unless ENV['KARI_DEBUG'] == 'true' or ENV['RUBYCOCOA_STANDALONEIFYING?']
  # Path from standalonify
  COCOA_APP_RESOURCES_DIR = File.expand_path(File.join(File.dirname(__FILE__), '../'))
  $LOAD_PATH.reject! { |d| d.index(File.dirname(COCOA_APP_RESOURCES_DIR))!=0 }
  $: << File.join(COCOA_APP_RESOURCES_DIR,"ThirdParty")
  $: << File.join(File.dirname(COCOA_APP_RESOURCES_DIR),"lib")
  ENV['GEM_HOME'] = ENV['GEM_PATH'] = File.join(COCOA_APP_RESOURCES_DIR,"RubyGems")
end

# Because we have a standalone app, all the default paths are removed.
# Thus RI will not be able to return any useful paths, so we should use this env var.
ENV["KARI_RI_PATH"] = '/usr/share/ri/1.8'

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
    # Eloy: Because we only use webrick atm, I commented this line. This cuts down the app by 1MB.
    # require 'rubygems' rescue LoadError
    require 'mongrel'
    require 'mongrel/camping'
    conf.server = :mongrel
  rescue LoadError 
    conf.server = :webrick
  end
end

require 'camping/server/' + conf.server.to_s

server = eval("Camping::Server::#{conf.server.to_s.capitalize}.new(conf, [File.join(DIR_LIB, 'kari.rb')])")
server.start unless ENV['RUBYCOCOA_STANDALONEIFYING?']
