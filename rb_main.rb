# This is requires the backend so that everything needed is also bundled when running standalonify.
require 'lib/server' if ENV['STANDALONEIFY_DUMP_FILE']

require 'osx/cocoa'
#$DEBUG = true
$KARI_DEBUG = false

if $KARI_DEBUG
  require File.expand_path('../../../../../SABookmarkBar/SABookmarkBar', File.dirname(__FILE__))
else
  require "SABookmarkBar/SABookmarkBar"
end

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
