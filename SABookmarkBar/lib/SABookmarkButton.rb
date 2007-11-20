#
#  SAFilterButton.rb
#  FilterBarTest
#
#  Created by Eloy Duran on 7/4/07.
#  Copyright (c) 2007 __MyCompanyName__. All rights reserved.
#

require 'osx/cocoa'

class OSX::SABookmarkButton < OSX::NSButton
  
  attr_reader :bookmark
  
  def initWithBookmark_target_OSVersion(bookmark, target, osVersion)
    if self.init
      @osVersion = osVersion
      if @osVersion >= 10.4
        self.cell = OSX::SABookmarkButtonCell.alloc.init
        self.buttonType = OSX::NSPushOnPushOffButton
        self.bezelStyle = OSX::NSRecessedBezelStyle
      else
        self.cell = OSX::SABookmarkButtonPreTigerCell.alloc.init
        self.buttonType = OSX::NSPushOnPushOffButton
        self.bordered = false
      end
      
      @bookmark, @target = bookmark, target
      self.title = @bookmark.title
      self.sizeToFit
      
      return self
    end
  end
  
  # drag and drop support methods
  
  def mouseDown(theEvent)
    # If the button is dragged @dragging will be set to true
    # But if the button isn't dragged the mouseUp event handler will call the original action.
    @dragging = false
  end
  
  def mouseUp(theEvent)
    if @dragging
      self.superview.doneDragging(self)
      # If the mouse pointer is still within the bounds of the button then set it to NSOnState
      # FIXME: this fails if the mouse is within the button's rect but the button will still animate away.
      self.state =
        if OSX::NSMouseInRect(self.convertPoint_fromView(theEvent.locationInWindow, nil), self.bounds, false)
          OSX::NSOnState
        else
          OSX::NSOffState
        end
    else
      # FIXME: Is there a better way to call a original set action?
      self.superview.bookmarkButtonClicked(self)
    end
  end
  
  def mouseDragged(theEvent)
    @dragging = true
    
    # What's the middle state?!
    self.state = OSX::NSOnState
    
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
  
  # moving/animation
  
  class << self
    attr_accessor :button_animation
    
    def stop_animating
      unless @button_animation.nil?
        @button_animation.stopAnimation if @button_animation.animating?
        @button_animation = nil
      end
    end
  end
  
  def move_to(new_x)
    if @osVersion >= 10.4
      end_position = self.frame
      end_position.origin.x = new_x
      animation = OSX::NSViewAnimation.alloc.initWithViewAnimations([{ OSX::NSViewAnimationTargetKey => self, OSX::NSViewAnimationEndFrameKey => OSX::NSValue.valueWithRect(end_position) }])
      animation.duration = 0.1
      #animation.duration = 3.0
      animation.startAnimation
      self.class.button_animation = animation
    else
      # pre tiger, no animation
      self.frameOrigin = OSX::NSMakePoint(new_x, self.frame.origin.y)
    end
  end
end