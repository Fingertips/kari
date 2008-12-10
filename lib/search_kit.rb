require 'osx/cocoa'

OSX.load_bridge_support_file(File.join(Rucola::RCApp.root_path, 'misc', 'BridgeSupport', 'SearchKit.bridgesupport'))

# Wrapper implementation around OS X's SearchKit.
module SearchKit
end

require File.expand_path('../search_kit/exceptions', __FILE__)
require File.expand_path('../search_kit/index', __FILE__)
require File.expand_path('../search_kit/match', __FILE__)