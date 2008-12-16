ENV['RUBYCOCOA_ENV'] = 'test'
ENV['RUBYCOCOA_ROOT'] = File.expand_path('../../', __FILE__)

require 'rubygems'
require 'test/unit'
require 'test/spec'
require 'mocha'
require 'rucola'
require 'rucola/test_helper'
require 'rucola/test_case'
require 'tmpdir'
require 'fileutils'

$:.push(File.expand_path('../test_helper', __FILE__))

require 'dangerous_methods_override'
require 'user_preferences'
require 'global_spec_helper'
require 'assert_difference'
require 'temporary_application_support_path'
require 'fixture_helpers'
require 'objective-c'

$:.push(File.expand_path('../../lib', __FILE__))

require 'core_ext'

ObjectiveC.require('lib/search_kit/Index', 'CoreServices')
ObjectiveC.require('lib/search_kit/Match')

require File.expand_path('../../config/boot', __FILE__)

TEST_ROOT = File.expand_path(File.dirname(__FILE__))

# Needed by some OSX classes, like WebView, to function properly.
require 'osx/cocoa'
Thread.new { OSX.CFRunLoopRun }

def silence_warnings
  old_verbose, $VERBOSE = $VERBOSE, nil
  yield
ensure
  $VERBOSE = old_verbose
end