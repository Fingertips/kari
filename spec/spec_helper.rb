TEST_ROOT_PATH = File.expand_path('..', __FILE__)

require 'rubygems'
gem 'mocha-macruby'
require 'mocha-on-bacon'

Bacon.extend Bacon::TestUnitOutput
Bacon.summary_on_exit

framework 'Cocoa'

ENV['KARI_ENV'] = 'test'

$:.unshift File.expand_path('../spec_helper', __FILE__)
require 'assert_difference'
require 'controllers'
require 'dangerous_methods_override'
require 'fixture_helpers'
require 'objective-c'
require 'temporary_application_support_path'
require 'user_preferences'

ObjectiveC.require('lib/search_kit/Match')
ObjectiveC.require('lib/search_kit/Index', 'CoreServices')
ObjectiveC.require('app/models/ScoredRubyName')

require File.expand_path('../../config/boot', __FILE__)

def show_logs(&block)
  level = log.level
  log.level = Log::DEBUG
  begin
    yield
  ensure
    log.level = level
  end
end

def show_backtrace(&block)
  yield
rescue Exception => e
  puts '---'
  p e
  e.backtrace.each do |line|
    puts "  #{line}"
  end
  raise
end

class Thread
  def self.start
    yield
  end
end