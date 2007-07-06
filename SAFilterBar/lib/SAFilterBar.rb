#
#  SAFilterBar.rb
#
#  Created by Eloy Duran <e.duran@superalloy.nl>
#
#  Original Objective-C FilterBar code from Logan Rockmore: http://burgundylogan.com/blog/?cat=15

require 'osx/cocoa'

class OSX::SAFilterBar < OSX::NSView
  LEFT_MARGIN = 5
  SPACING = 2
  
  def initWithFrame(frame)
    if super_initWithFrame(frame)
      @buttonX = LEFT_MARGIN
      
      @buttonsDictionary = [[]]
      
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
    @buttonsDictionary.each do |dict|
      dict.each do |obj|
        # FIXME: when resizing for some reason the button state always returns NSOffState,
        # this should be fixed for a filter bar, but is not necessary for Kari.
        #p obj.state
        selectedTitleArray.push obj.title if obj.state == OSX::NSOnState # save old selected buttons
        obj.removeFromSuperview unless obj.is_a? OSX::NSMenuItem # remove old buttons
      end
      
      dict.clear
      @buttonX = LEFT_MARGIN
      
      # remove overflow button
      if @overflowButton
        @overflowButton.removeFromSuperview
        @overflowMenu = nil
      end
    end
    @buttonsDictionary = [[]]
    
    # add new buttons
    self._addItemsWithTitles_withSelector_withSender(@originalArray, @originalSelector, @originalSender) if @originalArray != nil
    
    @buttonsDictionary.each do |dict|
      # select previous button
      selectedButton = nil
      dict.each_with_index do |obj, idx|
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
    @buttonsDictionary.each do |dict|
      dict[0].state = OSX::NSOnState
    end
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
      @buttonsDictionary.last.push newButton
      newButton.showsBorderOnlyWhileMouseInside = true
    else
      self.createOverflowMenu if @overflowMenu.nil?
      newMenuItem = OSX::NSMenuItem.alloc.initWithTitle_action_keyEquivalent(title, "performActionForButton:", "")
      newMenuItem.target = self
      @overflowMenu.addItem newMenuItem
      @buttonsDictionary.last.push newMenuItem
    end
  end
  
  def createButtonWithTitle(title)
    newButton = OSX::SAFilterButton.alloc.initWithOS(self.getOSVersion)
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
      
      @buttonsDictionary.last.push newButton
    else
      self.createOverflowMenu if @overflowMenu.nil?
      
      newMenuItem = OSX::NSMenuItem.separatorItem
      @overflowMenu.addItem newMenuItem
      
      @buttonsDictionary.last.push newMenuItem
    end
    
    @buttonsDictionary.push []
  end
  
  def removeAllItems
    @buttonsDictionary.each do |dict|
      # remove old buttons
      dict.each do |obj|
        obj.removeFromSuperview unless obj.is_a?(OSX::NSMenuItem)
      end
      dict.clear
      # remove overflow button
      if @overflowButton
        @overflowButton.removeFromSuperview
        @overflowMenu = nil
      end
    end
    @buttonsDictionary = [[]]
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
    @buttonsDictionary.each do |dict|
      if dict.include? button
        dict.each { |obj| obj.state = OSX::NSOffState }
        button.state = OSX::NSOnState
      end
    end
  end
  
  def getOSVersion
    @osVersion ||= OSX::NSDictionary.dictionaryWithContentsOfFile("/System/Library/CoreServices/SystemVersion.plist").objectForKey("ProductVersion").doubleValue
  end
  
  # accessor method
  
  def getSelectedButtonInSegment(segment)
    if segment < @buttonsDictionary.length
      @buttonsDictionary[segment].each_with_index do |obj, idx|
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
    if segment < @buttonsDictionary.length
      @buttonsDictionary[segment].each do |obj|
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
