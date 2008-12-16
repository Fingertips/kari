class BarView < OSX::NSView
  def initWithFrame(frame)
    if super_initWithFrame(frame)
      registerForWindowChangedKeyNotifications
      self
    end
  end
    
  def registerForWindowChangedKeyNotifications
    OSX::NSNotificationCenter.defaultCenter.addObserver_selector_name_object(self, :windowChangedKey, OSX::NSWindowDidResignKeyNotification, nil)
    OSX::NSNotificationCenter.defaultCenter.addObserver_selector_name_object(self, :windowChangedKey, OSX::NSWindowDidBecomeKeyNotification, nil)
  end
  
  def windowChangedKey(aNotification)
    self.needsDisplay = true
  end
  
  def selectedBackgroundColor
    [0.588, 0.588, 0.588, 1]
  end
  
  def selectedTopLineColor
    [0.753, 0.753, 0.753, 1]
  end
  
  def selectedBottomLineColor
    [0.251, 0.251, 0.251, 1]
  end
  
  def backgroundColor
    [0.812, 0.812, 0.812, 1]
  end
  
  def topLineColor
    [0.886, 0.886, 0.886, 1]
  end
  
  def bottomLineColor
    [0.529, 0.529, 0.529, 1]
  end
  
  def barColors
    if window.mainWindow?
      [selectedBackgroundColor, selectedTopLineColor, selectedBottomLineColor]
    else
      [backgroundColor, topLineColor, bottomLineColor]
    end
  end
  
  def drawRect(rect)
    @bar_height ||= bounds.size.height
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
end

class StatusBar < BarView
  def self.switch_methods(method_a, method_b)
    class_eval do
      alias_method "#{method_b}_original", method_b
      alias_method method_b, method_a
      alias_method method_a, "#{method_b}_original"
    end
  end
  
  %w{ topLineColor bottomLineColor }.each do |color|
    switch_methods color, "selected#{color[0,1].upcase}#{color[1..-1]}"
  end
end