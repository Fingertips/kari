#
#  SAOverflowButton.rb
#
#  Created by Eloy Duran <e.duran@superalloy.nl>
#
#  Original Objective-C FilterBar code from Logan Rockmore: http://burgundylogan.com/blog/?cat=15

require 'osx/cocoa'

class OSX::SAOverflowButton < OSX::NSButton
  OVERFLOW_IMAGE = OSX::NSImage.alloc.initWithContentsOfFile(File.join(File.dirname(File.expand_path(__FILE__)), '..', 'images', 'OverflowButton.tif'))
  OVERFLOW_IMAGE.template = true
  
  def init
    if super_init
      self.image = OVERFLOW_IMAGE
      self.bordered = false
      self.sizeToFit
      self
    end
  end
  
  def setBackgroundColor
    cell.backgroundColor = OSX::NSColor.colorWithDeviceRed_green_blue_alpha(*superview.barColors.first)
  end
  
  def drawRect(rect)
    setBackgroundColor
    super_drawRect(rect)
  end
  
  def displayMenu(timer)
    y = self.superview.frame.origin.y + self.frame.origin.y
    event = timer.userInfo.copy
    event.instance_variable_set(:@location, OSX::NSMakePoint(self.frame.origin.x, y))
    # FIXME: the event passed should call the mouseDown method when some item has been selected in the overflow menu.
    OSX::NSNotificationCenter.defaultCenter.addObserver_selector_name_object(self, :menuWillClose, OSX::NSMenuDidSendActionNotification, self.menu)
    OSX::NSMenu.popUpContextMenu_withEvent_forView(self.menu, event, self)
  end
  
  def mouseDown(theEvent)
    super_mouseDown(theEvent)
    timer = OSX::NSTimer.timerWithTimeInterval_target_selector_userInfo_repeats(0.0, self, 'displayMenu:', theEvent, false)
    OSX::NSRunLoop.currentRunLoop.addTimer_forMode(timer, "NSDefaultRunLoopMode")
  end
  
  def menuWillClose(sender)
    OSX::NSNotificationCenter.defaultCenter.removeObserver(self)
  end
end
