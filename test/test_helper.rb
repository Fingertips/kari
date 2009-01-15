require "pathname"

RUCOLA_ENV = 'test'
RUCOLA_ROOT = Pathname.new(File.expand_path('../../', __FILE__))

#require 'rubygems'
#require 'test/spec'
require 'mocha'
require 'tmpdir'
require 'fileutils'

$:.unshift "/Users/eloy/code/MacRuby/rucola/lib"
require 'rucola'
require 'rucola/test_helpers'
require 'rucola/test_spec'
require 'rucola/test_case'

$: << File.expand_path('../test_helper', __FILE__)

require 'dangerous_methods_override'
require 'user_preferences'
require 'global_spec_helper'
require 'assert_difference'
require 'temporary_application_support_path'
require 'fixture_helpers'

require 'objective-c'
ObjectiveC.require('lib/search_kit/Match')
ObjectiveC.require('lib/search_kit/Index', 'CoreServices')

require File.expand_path('../../config/boot', __FILE__)

#$: << File.expand_path('../../lib', __FILE__)

require 'core_ext'

TEST_ROOT = File.expand_path(File.dirname(__FILE__))

# Needed by some OSX classes, like WebView, to function properly.
Thread.new { CFRunLoopRun() }