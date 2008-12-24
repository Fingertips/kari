#
#  rb_main.rb
#  Crasher
#
#  Created by Eloy Duran on 12-10-07.
#  Copyright (c) 2007 __MyCompanyName__. All rights reserved.
#

require 'osx/cocoa'
require File.expand_path('../../../../../../../../lib/SACrashReporter', __FILE__)

def rb_main_init
  path = OSX::NSBundle.mainBundle.resourcePath.fileSystemRepresentation
  rbfiles = Dir.entries(path).select {|x| /\.rb\z/ =~ x}
  rbfiles -= [ File.basename(__FILE__) ]
  rbfiles.each do |path|
    require( File.basename(path) )
  end
end

# SACrashReporter.run_app do
#   if $0 == __FILE__ then
#     rb_main_init
#     OSX.NSApplicationMain(0, nil)
#   end
# end

SACrashReporter.run_app