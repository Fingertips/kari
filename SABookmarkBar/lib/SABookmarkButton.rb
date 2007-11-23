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
      self.font = OSX::NSFont.boldSystemFontOfSize(11)
      self.title = bookmark.title
      self.sizeToFit
      
      @dragging = @ignore_dragging = false
      @bookmark, @target = bookmark, target
      
      menu = OSX::NSMenu.alloc.initWithTitle('Contextual Menu')
      menu.insertItemWithTitle_action_keyEquivalent_atIndex('Open', :menu_open, '', 0)
      menu.insertItemWithTitle_action_keyEquivalent_atIndex('Delete', :menu_delete, '', 1)
      self.menu = menu
      
      return self
    end
  end
  
  # drag and drop support methods
  
  def dragging?
    @dragging
  end
  
  def ignore_further_dragging?
    @ignore_further_dragging
  end
  
  DRAG_TIMEOUT_THRESHOLD = 1 # seconds
  DRAG_OFFSET_THRESHOLD = 3 # pixels
  def check_drag_threshold(offset)
    if @started_drag_at.nil?
      @started_drag_at = Time.now
      time_difference = 0
    else
      time_difference = Time.now - @started_drag_at
    end
    
    # check if the drag operation is still within the timeout
    if time_difference < DRAG_TIMEOUT_THRESHOLD
      # check if the drag movement is over the threshold
      if offset.abs > DRAG_OFFSET_THRESHOLD
        @started_drag_at = nil
        @dragging = true
      end
    else
      # did not reach drag threshold, so ignore any further drag events
      @started_drag_at = nil
      @ignore_further_dragging = true
    end
  end
  
  def mouseDown(theEvent)
    self.highlight(true)
    # If the button is dragged @dragging will be set to true
    # But if the button isn't dragged the mouseUp event handler will call the original action.
    @dragging = false
  end
  
  def mouseUp(theEvent)
    if @dragging
      self.superview.doneDragging(self)
    else
      # FIXME: Is there a better way to call a original set action?
      self.superview.bookmarkButtonClicked(self)
    end
    # reset
    self.highlight(false)
    @dragging = @ignore_further_dragging = false
  end
  
  def mouseDragged(event)
    return if ignore_further_dragging?
    
    if not dragging?
      # check if we really want to perform a drag
      check_drag_threshold event.deltaX
    else
      new_x = self.frame.origin.x + event.deltaX
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
  
  # contextual menu methods
  
  def menu_open(sender)
    self.superview.bookmarkButtonClicked(self)
  end
  
  def menu_delete(sender)
    self.superview.delegate.removeBookmark(self)
  end
  
end