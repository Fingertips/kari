TEST_ROOT_PATH = File.expand_path('..', __FILE__)

require 'rubygems'
require 'bacon'
gem 'mocha-macruby'
require 'mocha-on-bacon'

Bacon.extend Bacon::TestUnitOutput
Bacon.summary_on_exit

framework 'Cocoa'

ENV['RUCOLA_ENV'] = 'test'

$:.unshift File.expand_path('../spec_helper', __FILE__)
require 'fixture_helpers'
require 'temporary_application_support_path'
require 'objective-c'

# ObjectiveC.require('lib/search_kit/Match')
# ObjectiveC.require('lib/search_kit/Index', 'CoreServices')
# ObjectiveC.require('app/models/ScoredRubyName')

system "xcodebuild -target KariTest -configuration Debug"
ENV['DYLD_FRAMEWORK_PATH'] = File.expand_path('../../build/Debug', __FILE__)
framework 'KariTest'

require File.expand_path('../../config/boot', __FILE__)