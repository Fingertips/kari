#!/usr/bin/env ruby

DIR_LIB = File.expand_path(File.dirname(__FILE__))
$:.unshift(DIR_LIB)

require 'ostruct'
require 'camping'
require 'camping/server'

conf = OpenStruct.new(:host => '0.0.0.0', :port => 3301)
conf.db = '/dev/null'
conf.rc = '/dev/null'

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
