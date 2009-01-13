class FilterBar < NSView
  STARTING_COLOR = NSColor.colorWithCalibratedWhite(0.91, alpha: 1.0)
  ENDING_COLOR = NSColor.colorWithCalibratedWhite(0.82, alpha: 1.0)
  LINE_COLOR = NSColor.colorWithCalibratedWhite(0.251, alpha: 1.0)
  ANGLE = 270
  
  def drawRect(rect)
    bounds = self.bounds
    
    gradient.drawInRect(bounds, angle: ANGLE)
    
    LINE_COLOR.set
    path = NSBezierPath.bezierPath
    path.lineWidth = 0
    path.moveToPoint(NSMakePoint(0, 0))
    path.lineToPoint(NSMakePoint(bounds.width, 0))
    path.closePath
    path.stroke
  end
  
  private
  
  def gradient
    @gradient ||= NSGradient.alloc.initWithStartingColor(STARTING_COLOR, endingColor: ENDING_COLOR)
  end
end