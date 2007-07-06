#
#  SAFilterButtonCell.rb
#
#  Created by Eloy Duran <e.duran@superalloy.nl>
#
#  Original Objective-C FilterBar code from Logan Rockmore: http://burgundylogan.com/blog/?cat=15

require 'osx/cocoa'

class OSX::SAFilterButtonCell < OSX::NSButtonCell
  
  def drawInteriorWithFrame_inView(cellFrame, controlView)
    if self.state == OSX::NSOnState
      super_drawInteriorWithFrame_inView(cellFrame, controlView)
    else
      topColor = self.controlView.superview.topColor
      bottomColor = self.controlView.superview.bottomColor
      
      aGradient = OSX::NSKeyedUnarchiver.unarchiveObjectWithData( OSX::NSKeyedArchiver.archivedDataWithRootObject( OSX::CTGradient.gradientWithBeginningColor_endingColor(bottomColor, topColor).retain ) )
      aGradient.fillRect_angle(cellFrame, 90)
      
      attributes = { OSX::NSForegroundColorAttributeName => OSX::NSColor.blackColor, OSX::NSFontAttributeName => OSX::NSFont.systemFontOfSize(12) }
      title = OSX::NSAttributedString.alloc.initWithString_attributes(self.title, attributes)
      rect = OSX::NSMakeRect(cellFrame.origin.x + 8, cellFrame.origin.y - 1, cellFrame.size.width, cellFrame.size.height)
      self.drawTitle_withFrame_inView(title, rect, controlView)
    end
  end
  
  def mouseEntered(theEvent)
    @originalState = self.controlView.state
    self.controlView.state = OSX::NSOnState
    self.controlView.needsDisplay = true
  end

  def mouseExited(theEvent)
    self.controlView.needsDisplay = true
    self.controlView.state = @originalState
  end
  
  # For Kari we need to disable this behaviour
  def mouseDown(theEvent)
    @originalState = (@originalState == OSX::NSOnState) ? OSX::NSOffState : OSX::NSOnState
  end
  
end
