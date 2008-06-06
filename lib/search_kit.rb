require 'osx/cocoa'

OSX.load_bridge_support_file(File.join(Rucola::RCApp.root_path, 'misc', 'BridgeSupport', 'SearchKit.bridgesupport'))

module SearchKit
end

require File.expand_path('search_kit/index', File.dirname(__FILE__))