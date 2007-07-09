#
#  rb_main.rb
#  Kari
#
#  Created by Eloy Duran on 7/2/07.
#  Copyright (c) 2007 __MyCompanyName__. All rights reserved.
#

require 'osx/cocoa'
#$DEBUG = true

# FIXME: When the bookmark bar stuff is done, load the lib as normal by only requiring the filter_bar.rb file.
# Until then these files are simply copied into the bundle so the build dir doesn't have to be removed everytime.
# But it's very important that this lib get's required before anything else, otherwise it leads to weird crashes.
require "SAFilterBar"
require "SAFilterButton"
require "SAFilterButtonCell"
require "SAFilterButtonPreTigerCell"
require "SAOverflowButton"

def rb_main_init
  path = OSX::NSBundle.mainBundle.resourcePath.fileSystemRepresentation
  rbfiles = Dir.entries(path).select {|x| /\.rb\z/ =~ x}
  rbfiles -= [ File.basename(__FILE__) ]
  rbfiles.each do |path|
    require( File.basename(path) )
  end
end

if $0 == __FILE__ then
  rb_main_init
  OSX.NSApplicationMain(0, nil)
end
