#
#  SAFilterButtonCell.rb
#
#  Created by Eloy Duran <e.duran@superalloy.nl>
#
#  Original Objective-C FilterBar code from Logan Rockmore: http://burgundylogan.com/blog/?cat=15

require 'osx/cocoa'

class OSX::SABookmarkButtonCell < OSX::NSButtonCell
  def init
    if super_init
      self.controlSize = OSX::NSSmallControlSize
      self
    end
  end
end