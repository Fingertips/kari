require 'rubygems'
gem 'mocha-macruby'
require 'mocha-on-bacon'

framework 'Cocoa'

ENV['RUCOLA_ENV'] = 'test'

require File.expand_path('../../config/boot', __FILE__)