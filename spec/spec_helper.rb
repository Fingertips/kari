TEST_ROOT_PATH = File.expand_path('..', __FILE__)

require 'rubygems'
gem 'mocha-macruby'
require 'mocha-on-bacon'

framework 'Cocoa'

ENV['RUCOLA_ENV'] = 'test'

$:.unshift File.expand_path('../spec_helper', __FILE__)
require 'fixture_helpers'
require 'temporary_application_support_path'
require 'objective-c'

require File.expand_path('../../config/boot', __FILE__)

ObjectiveC.require('lib/search_kit/Match')
ObjectiveC.require('lib/search_kit/Index', 'CoreServices')
ObjectiveC.require('app/models/ScoredRubyName')