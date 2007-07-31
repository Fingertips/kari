#
#  Created by Eloy Duran <e.duran@superalloy.nl>
#
#  Original Objective-C FilterBar code from Logan Rockmore: http://burgundylogan.com/blog/?cat=15
#
#  This lib depends on the CTGradient class to draw the gradients, available at http://blog.oofn.net/2006/01/15/gradients-in-cocoa/
#  It has been tested with version 1.5 and 1.6.

require "osx/cocoa"

require "#{File.dirname(File.expand_path(__FILE__))}/lib/SAFilterBar"
require "#{File.dirname(File.expand_path(__FILE__))}/lib/SAFilterButton"
require "#{File.dirname(File.expand_path(__FILE__))}/lib/SAFilterButtonCell"
require "#{File.dirname(File.expand_path(__FILE__))}/lib/SAFilterButtonPreTigerCell"
require "#{File.dirname(File.expand_path(__FILE__))}/lib/SAOverflowButton"