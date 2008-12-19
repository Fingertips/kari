# http://www.katoemba.net/makesnosenseatall/2008/01/09/nsview-with-gradient-background/

class ColorGradientView < OSX::NSView
  STARTING_COLOR = OSX::NSColor.colorWithCalibratedWhite_alpha(0.91, 1.0)
  ENDING_COLOR = OSX::NSColor.colorWithCalibratedWhite_alpha(0.82, 1.0)
  LINE_COLOR = OSX::NSColor.colorWithCalibratedWhite_alpha(0.251, 1.0)
  ANGLE = 270
  
  def drawRect(rect)
    bounds = self.bounds
    
    gradient.drawInRect_angle(bounds, ANGLE)
    
    LINE_COLOR.set
    path = OSX::NSBezierPath.bezierPath
    path.lineWidth = 0
    path.moveToPoint(OSX::NSMakePoint(0, 0))
    path.lineToPoint(OSX::NSMakePoint(bounds.width, 0))
    path.closePath
    path.stroke
  end
  
  def mouseDown(event)
    # nuffin' to see
  end
  
  private
  
  def gradient
    @gradient ||= OSX::NSGradient.alloc.initWithStartingColor_endingColor(STARTING_COLOR, ENDING_COLOR)
  end
end