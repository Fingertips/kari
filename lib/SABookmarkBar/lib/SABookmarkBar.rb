#
#  SABookmarkBar.rb
#
#  Created by Eloy Duran <e.duran@superalloy.nl>
#
#  Original Objective-C FilterBar code from Logan Rockmore: http://burgundylogan.com/blog/?cat=15

require 'osx/cocoa'

class OSX::SABookmarkBar < OSX::NSView
  attr_accessor :delegate, :bookmarks
  
  MARGIN = 5
  SPACING = 2
  
  def left_margin
    MARGIN
  end
  def right_margin
    unless @overflowMenu.nil?
      MARGIN + @overflowButton.frame.width
    else
      MARGIN
    end
  end
  def spacing
    SPACING
  end
  
  def initWithFrame(frame)
    if super_initWithFrame(frame)
      @buttonX = MARGIN
      @bookmarks = []
      @buttons = []
      @trackingRects = []
      
      @overflowButton = OSX::SAOverflowButton.alloc.init
      @overflowButton.target = self
      
      OSX::NSNotificationCenter.defaultCenter.addObserver_selector_name_object(self, :windowChangedKey, OSX::NSWindowDidResignKeyNotification, nil)
      OSX::NSNotificationCenter.defaultCenter.addObserver_selector_name_object(self, :windowChangedKey, OSX::NSWindowDidBecomeKeyNotification, nil)
      
      return self
    end
  end
  
  def bookmarks=(bookmarks)
    self.removeBookmarks unless @bookmarks.empty?
    @buttonX = MARGIN
    
    @bookmarks = bookmarks
    sorted = @bookmarks.sort_by { |b| b.order_index }
    sorted.each do |bookmark|
      self.addBookmarkButton(bookmark)
    end
    self.needsDisplay = true
  end
  
  def addBookmark(bookmark)
    @bookmarks.push(bookmark)
    self.addBookmarkButton(bookmark)
  end
  
  def windowChangedKey(aNotification)
    self.needsDisplay = true
  end
  
  def barColors
    # [[bacground color],        [top line color],         [bottom line color]     ]
    if self.window.keyWindow?
      [[0.588, 0.588, 0.588, 1], [0.753, 0.753, 0.753, 1], [0.251, 0.251, 0.251, 1]]
    else
      [[0.812, 0.812, 0.812, 1], [0.886, 0.886, 0.886, 1], [0.529, 0.529, 0.529, 1]]
    end
  end
  
  def drawRect(rect)
    @bar_height ||= self.bounds.size.height
    context = OSX::NSGraphicsContext.currentContext.graphicsPort
    backgroundColor, topLineColor, bottomLineColor = barColors
    
    # draw background
    OSX::CGContextSetRGBFillColor(context, *backgroundColor)
    OSX::CGContextFillRect(context, OSX::CGRect.new(rect.origin, rect.size))
    
    # white-ish top line
    from = [rect.origin.x, @bar_height]
    to = [rect.origin.x + rect.size.width, @bar_height]
    drawLine(context, from, to, topLineColor)
    
    # black-ish bottom line
    from = [rect.origin.x, 0]
    to = [rect.origin.x + rect.size.width, 0]
    drawLine(context, from, to, bottomLineColor)
  end
  
  def drawLine(context, from, to, color)
    OSX::CGContextSetLineWidth(context, 2.0)
    OSX::CGContextBeginPath(context)
    OSX::CGContextMoveToPoint(context, *from)
    OSX::CGContextAddLineToPoint(context, *to)
    OSX::CGContextSetRGBStrokeColor(context, *color)
    OSX::CGContextStrokePath(context)
  end
  
  def bookmarkButtonClicked(sender)
    @delegate.bookmarkClicked(sender.bookmark)
  end
  
  def createOverflowMenu
    @overflowMenu = OSX::NSMenu.alloc.init
    @overflowButton.menu = @overflowMenu
    
    # x, y coordinates
    buttonHeight = @overflowButton.frame.size.height
    viewHeight = self.frame.size.height
    buttonWidth = @overflowButton.frame.size.width
    viewWidth = self.frame.size.width
    
    buttonYCoordinate = (viewHeight - buttonHeight) / 2
    buttonXCoordinate = viewWidth - buttonWidth
    
    @overflowButton.frameOrigin = OSX::NSMakePoint(buttonXCoordinate, buttonYCoordinate)
    
    self.addSubview @overflowButton
  end
  
  def addBookmarkButton(bookmark)
    button = OSX::SABookmarkButton.alloc.initWithBookmark_target_action(bookmark, self, :bookmarkButtonClicked)
    
    # x, y coordinates
    buttonHeight = button.frame.size.height
    viewHeight = self.frame.size.height
    buttonYCoordinate = (viewHeight - buttonHeight) / 2
    buttonXCoordinate = @buttonX
    
    button.frameOrigin = OSX::NSMakePoint(buttonXCoordinate, buttonYCoordinate)

    # for next button
    @buttonX += button.frame.size.width + SPACING
    
    # add to view
    if @buttonX < (self.frame.size.width - @overflowButton.frame.size.width)
      self.addSubview(button)
      
      # make sure the previous button has this button as next responder
      @buttons.last.nextKeyView = button unless @buttons.last.nil?
      # and let's set the next one for if this is the last button
      #button.nextKeyView = resetKeyViewAfterLastButton unless keyViewAfterLastButton.nil?

      @buttons.push(button)
      button.showsBorderOnlyWhileMouseInside = true
      
      # drag & drop support
      self.addTrackingRectForButton(button)
      self.addPostitionForButton(button)
      
      button
    else
      if @overflowMenu.nil?
        # make sure the nextKeyView chain is set back as it was
        resetKeyViewsAfterLastButton unless keyViewsAfterLastButton.nil?
        self.createOverflowMenu
      end
      menu_item = OSX::SABookmarkMenuItem.alloc.initWithBookmark_action_keyEquivalent(bookmark, :bookmarkButtonClicked, "")
      menu_item.target = self
      @overflowMenu.addItem menu_item
      @buttons.push menu_item
      menu_item
    end
  end
  
  # These key view methods are not the way it should be...
  
  def storeKeyViewsAfterLastButton
    return if @next_key_views_after_last_button
    @buttons.reverse.each do |obj|
      next if obj.is_a? OSX::NSMenuItem
      @next_key_views_after_last_button = [obj.nextKeyView, obj.nextKeyView.nextKeyView]
      break
    end
  end
  
  def keyViewsAfterLastButton
    @next_key_views_after_last_button
  end
  
  def resetKeyViewsAfterLastButton
    @buttons.last.nextKeyView = @next_key_views_after_last_button.first
    @next_key_views_after_last_button.first.nextKeyView = @next_key_views_after_last_button.last
  end
  
  def removeBookmarks
    storeKeyViewsAfterLastButton
    
    # remove old stuff
    @buttonPositions = []
    
    @buttons.each do |obj|
      unless obj.is_a? OSX::NSMenuItem # remove old buttons
        obj.removeFromSuperview
      end
    end
    @buttons = []
    
    if @overflowButton
      @overflowButton.removeFromSuperview
      @overflowMenu = nil
    end
    
    self.removeAllTrackingRects
  end
  
  def resizeSubviewsWithOldSize(oldBoundsSize)
    # add new stuff
    self.bookmarks = @bookmarks
  end

  def setReorderedItemsDelegate_withSelector(delegate, selector)
    @reorderedItemsDelegate_withSelector = [delegate, selector]
  end

  def mouseEntered(theEvent)
    # bring the button to the foreground
    unless self.dragging?
      button = @trackingRects[theEvent.trackingNumber]
      button.removeFromSuperview
      self.addSubview button
    end
  end
  
  def addPostitionForButton(button)
    (@buttonPositions ||= []) << { :button => button, :original_x => button.frame.origin.x }
  end
  
  def addTrackingRectForButton(button)
    @trackingRects ||= {}
    @trackingRects[self.addTrackingRect_owner_userData_assumeInside(button.frame, self, nil, false)] = button
  end
  
  def removeAllTrackingRects
    @trackingRects.each {|tag, button| self.removeTrackingRect(tag) }
    @trackingRects = {}
  end
  
  def resetTrackingRects
    self.removeAllTrackingRects
    # setup the new tracking rects hash
    @buttons.each do |obj|
      unless obj.is_a? OSX::NSMenuItem
        self.addTrackingRectForButton(obj)
      end
    end
  end
  
  def dragging?
    @dragging_button_index != nil
  end
  
  def draggingButton_xCoordinate(button)
    unless self.dragging?
      @buttonPositions.each_with_index do |button_and_orginal_x, idx|
        if button_and_orginal_x[:button] == button
          # this is the button that is being dragged
          @dragging_button_index = @dragging_button_original_index = idx
          break
        end
      end
      # set this to it's own original value, this is needed if a button is dragged a bit but no reordering is done.
      @new_x_for_dragging_button = @buttonPositions[@dragging_button_index][:original_x]
      # setup the initial values for the move trigger x coordinates
      self.setMoveTriggerCoordinates
    end
    
    # if there is a next button and if the current position of the dragging button is over a button that we haven't moved yet
    if @next_x_for_move_trigger != nil && button.frame.origin.x > @next_x_for_move_trigger
      OSX::SABookmarkButton.stop_animating
      
      # the button that will be moved
      over_button = @buttonPositions[@dragging_button_index +1][:button]
      # store a reference for where the dragging button should come if it was released now
      @new_x_for_dragging_button = @buttonPositions[@dragging_button_index][:original_x] + over_button.frame.width + SPACING
      # calculate the new x coordinate for the moving button
      new_x_for_over_button = over_button.frame.origin.x - button.frame.width - SPACING
      # do it!
      self.processMove(over_button, new_x_for_over_button, +1)
      
    # if there is a previous button and if the current position of the dragging button is over a button that we haven't moved yet
    elsif @prev_x_for_move_trigger != nil && button.frame.origin.x < @prev_x_for_move_trigger
      OSX::SABookmarkButton.stop_animating
      
      # the button that will be moved
      over_button = @buttonPositions[@dragging_button_index -1][:button]
      # store a reference for where the dragging button should come if it was released now
      @new_x_for_dragging_button = over_button.frame.origin.x
      # calculate the new x coordinate for the moving button
      new_x_for_over_button = (@buttonPositions[@dragging_button_index][:original_x] + button.frame.width) - over_button.frame.width # + SPACING
      # do it!
      self.processMove(over_button, new_x_for_over_button, -1)
    end
  end
  
  def processMove(over_button, new_x_for_over_button, drag_direction)
    #move_button_to(over_button, new_x_for_over_button)
    over_button.move_to(new_x_for_over_button)
    
    # update the original_x values and switch the buttons in the @buttonPositions array
    @buttonPositions[@dragging_button_index][:original_x] = @new_x_for_dragging_button
    @buttonPositions[@dragging_button_index + drag_direction][:original_x] = new_x_for_over_button
    @buttonPositions = @buttonPositions.switch(@dragging_button_index, @dragging_button_index + drag_direction)
    
    # update the current dragging index
    @dragging_button_index = @dragging_button_index + drag_direction
    
    # update the new move trigger
    self.setMoveTriggerCoordinates
  end
  
  def setMoveTriggerCoordinates
    # Store a reference to the next x coordinate that will trigger a move if there is a next button.
    # It should be triggered once the right side of the dragging button is at the point where the right side of the over_button is.
    @next_x_for_move_trigger = @buttonPositions[@dragging_button_index +1].nil? ? nil : (@buttonPositions[@dragging_button_index +1][:original_x] + @buttonPositions[@dragging_button_index +1][:button].frame.width - @buttonPositions[@dragging_button_index][:button].frame.width)
    # store a reference to the previous x coordinate that will trigger a move if there is a previous button.
    # It should be triggered once the left side of the dragging button is at the left side of the over_button, but because of the margin at the left add one pixel.
    @prev_x_for_move_trigger = (@dragging_button_index -1) < 0 ? nil : (@buttonPositions[@dragging_button_index -1][:original_x] + 1)
  end
  
  def doneDragging(button)
    return if @new_x_for_dragging_button.nil? # for some reason this gets called again after the dragging has already ended...
    
    # snap the button to the last good location
    OSX::SABookmarkButton.stop_animating
    button.move_to(@new_x_for_dragging_button)
    
    unless @dragging_button_index == @dragging_button_original_index
      @bookmarks = @bookmarks.move(@dragging_button_original_index, @dragging_button_index)
      # callback
      @delegate.bookmarksReordered(button.bookmark)
    end
    
    # reset the states
    @dragging_button_index = @dragging_button_original_index = @new_x_for_dragging_button = @next_x_for_move_trigger = @prev_x_for_move_trigger = nil
    
    self.resetTrackingRects
  end

end
