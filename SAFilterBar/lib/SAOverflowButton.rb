#
#  SAOverflowButton.rb
#
#  Created by Eloy Duran <e.duran@superalloy.nl>
#
#  Original Objective-C FilterBar code from Logan Rockmore: http://burgundylogan.com/blog/?cat=15

require 'osx/cocoa'

class OSX::SAOverflowButton < OSX::NSButton
  def init
    if super_init
      self.image = OSX::NSImage.imageNamed("OverflowButton.tif")
      self.bordered = false
      self.sizeToFit
      return self
    end
  end
  
  def displayMenu(timer)
    y = self.superview.frame.origin.y + self.frame.origin.y
    theEvent = timer.userInfo.copy
    theEvent.instance_variable_set(:@location, OSX::NSMakePoint(self.frame.origin.x, y))
    # FIXME: the event passed should call the mouseDown method when some item has been selected in the overflow menu.
    OSX::NSMenu.popUpContextMenu_withEvent_forView(self.menu, theEvent, self)
    timer.invalidate
  end

  def mouseDown(theEvent)
    self.highlight false
    self.image = OSX::NSImage.imageNamed("OverflowButtonPressed.tif")
    timer = OSX::NSTimer.timerWithTimeInterval_target_selector_userInfo_repeats(0.0, self, 'displayMenu:', theEvent, false)
    OSX::NSRunLoop.currentRunLoop.addTimer_forMode(timer, "NSDefaultRunLoopMode")
  end
  
  def mouseUp(theEvent)
    self.highlight false
    self.image = OSX::NSImage.imageNamed("OverflowButton.tif")
  end
end
