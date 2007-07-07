#
#  SAFilterBar.rb
#
#  Created by Eloy Duran <e.duran@superalloy.nl>
#
#  Original Objective-C FilterBar code from Logan Rockmore: http://burgundylogan.com/blog/?cat=15

require 'osx/cocoa'

class OSX::SABar < OSX::NSView
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
      
      @segments = [[]]
      
      @overflowButton = OSX::SAOverflowButton.alloc.init
      @overflowButton.target = self

      @topColor, @bottomColor = '', ''
      self.setBlueBackground
      
      return self
    end
  end
  
  def drawRect(rect)
    topColorCopy, bottomColorCopy = self.topColor, self.bottomColor
    if topColorCopy and bottomColorCopy
      aGradient = OSX::NSKeyedUnarchiver.unarchiveObjectWithData( OSX::NSKeyedArchiver.archivedDataWithRootObject( OSX::CTGradient.gradientWithBeginningColor_endingColor(topColorCopy, bottomColorCopy).retain ) )
      aGradient.fillRect_angle(rect, 90)
    end
    OSX::NSColor.blackColor.set
    OSX::NSBezierPath.strokeLineFromPoint_toPoint OSX::NSMakePoint(0,0), OSX::NSMakePoint(rect.size.width, 0)
  end
  
  def resizeSubviewsWithOldSize(oldBoundsSize)
    selectedTitleArray = []
    @segments.each do |items|
      items.each do |obj|
        # FIXME: when resizing for some reason the button state always returns NSOffState,
        # this should be fixed for a filter bar, but is not necessary for Kari.
        #p obj.state
        selectedTitleArray.push obj.title if obj.state == OSX::NSOnState # save old selected buttons
        obj.removeFromSuperview unless obj.is_a? OSX::NSMenuItem # remove old buttons
      end
      
      items.clear
      @buttonX = LEFT_MARGIN
      
      # remove overflow button
      if @overflowButton
        @overflowButton.removeFromSuperview
        @overflowMenu = nil
      end
    end
    @segments = [[]]
    
    # add new buttons
    self._addItemsWithTitles_withSelector_withSender(@originalArray, @originalSelector, @originalSender) if @originalArray != nil
    
    @segments.each do |items|
      # select previous button
      selectedButton = nil
      items.each_with_index do |obj, idx|
        if obj.title.isEqualTo selectedTitleArray[idx]
          selectedButton = obj
          break
        end
      end
      selectedButton.state = OSX::NSOnState unless selectedButton.nil?
    end
  end
  
  # Add button
  
  def addItemsWithTitles_withSelector_withSender(array, selector, sender)
    self._addItemsWithTitles_withSelector_withSender(array, selector, sender)
  end
  
  def _addItemsWithTitles_withSelector_withSender(titles, selector, sender)
    titles.each do |title|
      if title == "DIVIDER"
        self.addDivider
      else
        self.addButtonWithTitle(title)
      end
    end
    
    if @originalArray.nil?
      @originalArray = titles
      @originalSelector = selector
      @originalSender = sender
    end
  end
  
  def addButtonWithTitle(title)
    newButton = self.createButtonWithTitle(title)
    newButton.action = "performActionForButton:"
    newButton.target = self
    
    # x, y coordinates
    buttonHeight = newButton.frame.size.height
    viewHeight = self.frame.size.height
    buttonYCoordinate = (viewHeight - buttonHeight) / 2
    buttonXCoordinate = @buttonX
    
    newButton.frameOrigin = OSX::NSMakePoint(buttonXCoordinate, buttonYCoordinate)

    # for next button
    @buttonX += newButton.frame.size.width + SPACING
    
    # add to view
    if @buttonX < (self.frame.size.width - @overflowButton.frame.size.width)
      self.addSubview newButton
      @segments.last.push newButton
      newButton.showsBorderOnlyWhileMouseInside = true
      return newButton
    else
      self.createOverflowMenu if @overflowMenu.nil?
      newMenuItem = OSX::NSMenuItem.alloc.initWithTitle_action_keyEquivalent(title, "performActionForButton:", "")
      newMenuItem.target = self
      @overflowMenu.addItem newMenuItem
      @segments.last.push newMenuItem
      return newMenuItem
    end
  end
  
  def createButtonWithTitle(title)
    newButton = OSX.const_get("#{self.class.to_s[5..-4]}Button").alloc.initWithOS(self.getOSVersion)
    newButton.title = title
    newButton.sizeToFit
    return newButton
  end
  
  def addDivider
    if @buttonX < (self.frame.size.width - @overflowButton.frame.size.width)
      @buttonX += 3
      
      newButton = OSX::NSButton.alloc.init
      newButton.image = OSX::NSImage.imageNamed("OverflowDivider.png")
      newButton.bordered = false
      newButton.sizeToFit
      
      # set x,y coordinates
      buttonHeight = newButton.frame.size.height
      viewHeight = self.frame.size.height
      buttonYCoordinate = (viewHeight - buttonHeight) / 2
      buttonXCoordinate = @buttonX
      
      newButton.frameOrigin = OSX::NSMakePoint(buttonXCoordinate, buttonYCoordinate)
      
      # for next button
      @buttonX += newButton.frame.size.width + 3 + SPACING
      
      # add to view
      self.addSubview newButton
      
      @segments.last.push newButton
    else
      self.createOverflowMenu if @overflowMenu.nil?
      
      newMenuItem = OSX::NSMenuItem.separatorItem
      @overflowMenu.addItem newMenuItem
      
      @segments.last.push newMenuItem
    end
    
    @segments.push []
  end
  
  def removeAllItems
    @segments.each do |items|
      # remove old buttons
      items.each do |obj|
        obj.removeFromSuperview unless obj.is_a?(OSX::NSMenuItem)
      end
      items.clear
      # remove overflow button
      if @overflowButton
        @overflowButton.removeFromSuperview
        @overflowMenu = nil
      end
    end
    @segments = [[]]
    @originalArray = @originalSelector = @originalSender = nil
    @buttonX = LEFT_MARGIN
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
  
  def performActionForButton(button)
    self.deselectAllButtonsExcept button
    @originalSender.performSelector @originalSelector
  end
  
  def deselectAllButtonsExcept(button)
    @segments.each do |items|
      if items.include? button
        items.each { |obj| obj.state = OSX::NSOffState }
        button.state = OSX::NSOnState
      end
    end
  end
  
  def getOSVersion
    @osVersion ||= OSX::NSDictionary.dictionaryWithContentsOfFile("/System/Library/CoreServices/SystemVersion.plist").objectForKey("ProductVersion").doubleValue
  end
  
  # accessor method
  
  def getSelectedButtonInSegment(segment)
    if segment < @segments.length
      @segments[segment].each_with_index do |obj, idx|
        return [idx, obj] if obj.state == OSX::NSOnState
      end
    end
  end
  
  def getSelectedTitleInSegment(segment)
    self.getSelectedButtonInSegment(segment).last.title
  end
  
  def getSelectedIndexInSegment(segment)
    self.getSelectedButtonInSegment(segment).first
  end
  
  def selectTitle_inSegment(title, segment)
    if segment < @segments.length
      @segments[segment].each do |obj|
        if obj.title == title
          obj.state = OSX::NSOnState
          self.performActionForButton obj
          return true
        end
      end
    end
    false
  end
  
  # coloring
  
  def createColor(color)
    red, green, blue, alpha = color.to_s.split[1..-1].map {|n| n.to_f }
    OSX::NSColor.colorWithCalibratedRed_green_blue_alpha(red, green, blue, alpha)
  end
  
  def topColor; self.createColor @topColor; end
  def bottomColor; self.createColor @bottomColor; end
  
  def setBlueBackground
    self.createBackground :topColor => [182.0, 192.0, 207.0, 1.0], :bottomColor => [203.0, 210.0, 221.0, 1.0]
  end
  
  def setGrayBackground
    self.createBackground :topColor => [181.0, 181.0, 181.0, 1.0], :bottomColor => [216.0, 216.0, 216.0, 1.0]
  end
  
  def createBackground(colors)
    @topColor = self.stringForRedGreenBlueAlpha(*colors[:topColor])
    @bottomColor = self.stringForRedGreenBlueAlpha(*colors[:bottomColor])
    self.needsDisplay = true
  end
  
  # FIXME: look into why they chose to use a string instead of a color object
  def stringForRedGreenBlueAlpha(red, green, blue, alpha)
    OSX::NSString.alloc.initWithString OSX::NSColor.colorWithCalibratedRed_green_blue_alpha(red/255.0, green/255.0, blue/255.0, alpha).description
  end
end

class OSX::SAFilterBar < OSX::SABar
  def addItemsWithTitles_withSelector_withSender(array, selector, sender)
    super
    # Set the first button in each segment to NSOnState
    @segments.each do |items|
      items[0].state = OSX::NSOnState
    end
  end
end

class OSX::SABookmarkBar < OSX::SABar
  def addButtonWithTitle(title)
    item = super
    
    unless item.is_a? OSX::NSMenuItem
      # drag & drop support
      self.addTrackingRectForButton(item)
      self.addOriginalPostitionForButton(item)
    end
  end
  
  def mouseEntered(theEvent)
    button = @trackingRects[theEvent.trackingNumber]
    puts "Mouse entered rect: #{button.title}"    
    button.state = OSX::NSOnState
    button.removeFromSuperview
    self.addSubview button
  end
  
  def mouseExited(theEvent)
    button = @trackingRects[theEvent.trackingNumber]
    button.state = OSX::NSOffState
  end
  
  def addOriginalPostitionForButton(button)
    #puts button.class
    (@originalPositions ||= []) << { :button => button, :original_x => button.frame.origin.x }
  end
  
  def addTrackingRectForButton(button)
    @trackingRects ||= {}
    @trackingRects[self.addTrackingRect_owner_userData_assumeInside(button.frame, self, nil, false)] = button
  end
  
  def trackingRectTagForButton(for_button)
    @trackingRects.each do |tag, button|
      return tag if button == for_button
    end
  end
  
  def draggingButton_xCoordinate(button)
    if @dragging_button_index.nil?
      @originalPositions.each_with_index do |button_and_orginal_x, idx|
        if button_and_orginal_x[:button] == button
          @dragging_button_index = idx
          break
        end
      end
    end
    
    @next_x_for_over_button ||= @originalPositions[@dragging_button_index.next][:original_x]
    
    # if there is a next button and if the current position of the dragging button is over a button that we haven't moved yet
    if @originalPositions[@dragging_button_index.next] != nil && button.frame.origin.x > @next_x_for_over_button
      # the button that will be moved
      over_button = @originalPositions[@dragging_button_index.next][:button]
      
      # store a reference for where the dragging button should come if it was released now
      @new_x_for_dragging_button = @originalPositions[@dragging_button_index][:original_x] + over_button.frame.width + SPACING
      
      # store a reference for where the next button will start
      @next_x_for_over_button = @originalPositions[@dragging_button_index + 2][:original_x] unless @originalPositions[@dragging_button_index + 2].nil?
      
      # create the new x coordinate for the moving button
      new_x_for_over_button = over_button.frame.origin.x - button.frame.width - SPACING
      
      # move the button
      over_button.frameOrigin = OSX::NSMakePoint(new_x_for_over_button, over_button.frame.origin.y)
      
      # update the original_x values and switch the buttons in the @originalPositions array
      @originalPositions[@dragging_button_index][:original_x] = @new_x_for_dragging_button
      @originalPositions[@dragging_button_index.next][:original_x] = new_x_for_over_button
      @originalPositions = @originalPositions.switch(@dragging_button_index, @dragging_button_index.next)
      
      @dragging_button_index = @dragging_button_index.next
      
    # elsif new_x < @originalPositions[@dragging_button_index - 1][:original_x]
    #   over_button = @originalPositions[@dragging_button_index - 1][:button]
    #   over_button.frameOrigin = OSX::NSMakePoint(@originalPositions[@dragging_button_index][:button], over_button.frame.origin.y)
    end
  end
  
  def doneDragging(button)
    # snap the button to the last good location
    button.frameOrigin = OSX::NSMakePoint(@new_x_for_dragging_button, button.frame.origin.y)
    self.needsDisplay = true
    
    # reset the states
    @dragging_button_index = @new_x_for_over_button = @new_x_for_dragging_button = nil
    
    # unregister all tracking rects
    @trackingRects.each {|tag, button| self.removeTrackingRect(tag) }
    # setup the new tracking rects hash and the original positions array
    @trackingRects = {}
    #@originalPositions = []
    @segments.each do |items|
      items.each do |item|
        unless item.is_a? OSX::NSMenuItem
          self.addTrackingRectForButton(item)
          #self.addOriginalPostitionForButton(item)
        end
      end
    end
  end
  
end

class Array
  def switch(idx1, idx2)
    self_dup = self.dup
    self_dup[idx1], self_dup[idx2] = self_dup.values_at(idx2, idx1)
    return self_dup
  end
end