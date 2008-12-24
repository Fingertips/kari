class StatusBar < OSX::NSView
  def selectedBackgroundColor
    [0.588, 0.588, 0.588, 1]
  end
  
  def selectedTopLineColor
    [0.78, 0.78, 0.78, 1]
  end
  
  def selectedSeparatorLineColor
    [0.251, 0.251, 0.251, 1]
  end
  
  def backgroundColor
    [0.812, 0.812, 0.812, 1]
  end
  
  def topLineColor
    [0.902, 0.902, 0.902, 1]
  end
  
  def separatorLineColor
    [0.529, 0.529, 0.529, 1]
  end
  
  # --------------------------
  
  def initWithFrame(frame)
    if super_initWithFrame(frame)
      [OSX::NSWindowDidResignKeyNotification, OSX::NSWindowDidBecomeKeyNotification].each do |name|
        OSX::NSNotificationCenter.defaultCenter.addObserver_selector_name_object(self, :windowChangedKey, name, nil)
      end
      self
    end
  end
  
  def windowChangedKey(aNotification)
    self.needsDisplay = true
  end
  
  def barColors
    if window.mainWindow?
      [selectedSeparatorLineColor, selectedTopLineColor, selectedBackgroundColor]
    else
      [separatorLineColor, topLineColor, backgroundColor]
    end
  end
  
  def drawRect(rect)
    @bar_height ||= bounds.size.height
    context = OSX::NSGraphicsContext.currentContext.graphicsPort
    separatorLineColor, topLineColor, backgroundColor = barColors
    
    # draw background
    OSX::CGContextSetRGBFillColor(context, *backgroundColor)
    OSX::CGContextFillRect(context, OSX::CGRect.new(rect.origin, rect.size))
    
    # white-ish top line
    from = [rect.origin.x, (@bar_height - 1)]
    to = [rect.origin.x + rect.size.width, (@bar_height - 1)]
    drawLine(context, from, to, topLineColor)
    
    # black-ish separator line
    from = [rect.origin.x, @bar_height]
    to = [rect.origin.x + rect.size.width, @bar_height]
    drawLine(context, from, to, separatorLineColor)
  end
  
  def drawLine(context, from, to, color)
    OSX::CGContextSetLineWidth(context, 1.0)
    OSX::CGContextBeginPath(context)
    OSX::CGContextMoveToPoint(context, *from)
    OSX::CGContextAddLineToPoint(context, *to)
    OSX::CGContextSetRGBStrokeColor(context, *color)
    OSX::CGContextStrokePath(context)
  end
end