#
#  SAFilterButton.rb
#  FilterBarTest
#
#  Created by Eloy Duran on 7/4/07.
#  Copyright (c) 2007 Fingertips. All rights reserved.
#

require 'osx/cocoa'

class OSX::SABookmarkButton < OSX::NSButton
  MENU_ITEMS = [['Open', :menu_open], ['Delete', :menu_delete]]
  
  attr_reader :bookmark
  
  def initWithBookmark_target_action(bookmark, target, action)
    if self.init
      @bookmark, @target, @action = bookmark, target, action
      @dragging = @ignore_dragging = false
      
      setup_cell
      setup_button
      setup_menu
      
      self
    end
  end
  
  def setup_button
    self.buttonType = OSX::NSPushOnPushOffButton
    self.bezelStyle = OSX::NSRecessedBezelStyle
    self.font = OSX::NSFont.boldSystemFontOfSize(11)
    self.title = @bookmark.title
    self.sizeToFit
  end
  
  def setup_cell
    self.cell = OSX::NSButtonCell.alloc.init
    self.cell.target = self
    self.cell.action = :bookmarkButtonClicked
    self.cell.controlSize = OSX::NSSmallControlSize
  end
  
  def setup_menu
    self.menu = OSX::NSMenu.alloc.initWithTitle('Contextual Menu')
    MENU_ITEMS.each_with_index {|options, idx| self.menu.insertItemWithTitle_action_keyEquivalent_atIndex(options.first, options.last, '', idx) }
  end
  
  def redraw_bar
    self.superview.needsDisplayInRect = self.frame
  end
  
  def bookmarkButtonClicked(sender)
    @target.send(@action, self)
    self.state = OSX::NSOffState
  end
  
  # key methods
  
  def accepsFirstResponder
    true
  end
  
  def becomeFirstResponder
    #p @target.instance_variable_get(:@buttons)
    #p self.nextKeyView
    redraw_bar
    true
  end
  
  def resignFirstResponder
    self.highlight(false)
    self.state = OSX::NSOffState
    redraw_bar
    true
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
      #self.needsDisplay = true
      #self.superview.needsDisplay = true
    
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
    end_position = self.frame
    end_position.origin.x = new_x
    animation = OSX::NSViewAnimation.alloc.initWithViewAnimations([{ OSX::NSViewAnimationTargetKey => self, OSX::NSViewAnimationEndFrameKey => OSX::NSValue.valueWithRect(end_position) }])
    animation.duration = 0.1
    #animation.duration = 3.0
    animation.startAnimation
    self.class.button_animation = animation
  end
  
  # contextual menu methods
  
  def menu_open(sender)
    self.superview.bookmarkButtonClicked(self)
  end
  
  def menu_delete(sender)
    self.superview.delegate.removeBookmark(self)
  end
  
end