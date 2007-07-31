#
#  SAFilterButtonCell.rb
#
#  Created by Eloy Duran <e.duran@superalloy.nl>
#
#  Original Objective-C FilterBar code from Logan Rockmore: http://burgundylogan.com/blog/?cat=15

require 'osx/cocoa'

class OSX::SABookmarkButtonCell < OSX::NSButtonCell
  def drawInteriorWithFrame_inView(cellFrame, controlView)
    if self.state == OSX::NSOnState
      super_drawInteriorWithFrame_inView(cellFrame, controlView)
    else
      aGradient = self.controlView.superview.backgroundGradient
      aGradient.fillRect_angle(cellFrame, 270)
      
      attributes = { OSX::NSForegroundColorAttributeName => (self.controlView.superview.window.isKeyWindow ? OSX::NSColor.textColor : OSX::NSColor.disabledControlTextColor),
                     OSX::NSFontAttributeName => OSX::NSFont.systemFontOfSize(12) }
      
      title = OSX::NSAttributedString.alloc.initWithString_attributes(self.title, attributes)
      rect = OSX::NSMakeRect(cellFrame.origin.x + 8, cellFrame.origin.y - 1, cellFrame.size.width, cellFrame.size.height)
      self.drawTitle_withFrame_inView(title, rect, controlView)
    end
  end
end