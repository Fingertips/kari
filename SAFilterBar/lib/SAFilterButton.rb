#
#  SAFilterButton.rb
#  FilterBarTest
#
#  Created by Eloy Duran on 7/4/07.
#  Copyright (c) 2007 __MyCompanyName__. All rights reserved.
#

require 'osx/cocoa'
require "SAFilterButtonCell"

class OSX::SABarButton < OSX::NSButton
  
  def initWithOS(osVersion)
    if self.init
      if osVersion >= 10.4
        self.cell = OSX.const_get("#{self.class.to_s[5..-1]}Cell").alloc.init
        self.buttonType = OSX::NSPushOnPushOffButton
        self.bezelStyle = OSX::NSRecessedBezelStyle
      else
        self.cell = OSX.const_get("#{self.class.to_s[5..-1]}PreTigerCell").alloc.init
        self.buttonType = OSX::NSPushOnPushOffButton
        self.bordered = false
      end
      return self
    end
  end
  
  def mouseDown(theEvent)
    self.cell.mouseDown(theEvent) if self.cell.respond_to? :mouseDown 
    super_mouseDown(theEvent)
  end
end

class OSX::SAFilterButton < OSX::SABarButton
end

class OSX::SABookmarkButton < OSX::SABarButton
  def mouseDown(theEvent)
    # If the button is dragged @draggin will be set to true
    # But if the button isn't dragged the mouseUp event handler will call the original action.
    @dragging = false
  end
  
  def mouseUp(theEvent)
    if @dragging
      self.superview.doneDragging(self)
    else
      # FIXME: Is there a better way to call a original set action?
      self.superview.performActionForButton(self)
    end
  end
  
  def mouseDragged(theEvent)
    @dragging = true
    
    new_x = self.frame.origin.x + theEvent.deltaX
    if new_x < self.superview.left_margin
      # can't move to the left beyond the superviews frame + margin
      new_x = self.superview.left_margin
    elsif new_x > (self.superview.frame.width - self.frame.width - self.superview.right_margin)
      # can't move to the right beyond the superviews frame
      new_x = self.superview.frame.width - self.frame.width - self.superview.right_margin
    end
    
    self.frameOrigin = OSX::NSMakePoint(new_x, self.frame.origin.y)
    self.needsDisplay = true
    self.superview.needsDisplay = true
    
    # report position back to the bookmark bar
    self.superview.draggingButton_xCoordinate(self)
  end
end