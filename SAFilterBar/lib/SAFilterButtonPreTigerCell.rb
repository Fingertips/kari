#
#  SAFilterButtonPreTigerCell.rb
#
#  Created by Eloy Duran <e.duran@superalloy.nl>
#
#  Original Objective-C FilterBar code from Logan Rockmore: http://burgundylogan.com/blog/?cat=15

require 'osx/cocoa'

class SAFilterButtonPreTigerCell < OSX::NSButtonCell
  # - (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
  # { 
  #   NSString *stringValue = [self title];
  #   NSFont *font = [self font];
  #   NSColor *textColor;
  # 
  #   if( [self state] == NSOnState ) {
  # 
  #     [[NSColor lightGrayColor] set];
  #     NSRectFill(cellFrame);
  # 
  #     textColor = [NSColor whiteColor];
  #   } else {
  #     textColor = [NSColor blackColor];
  #   }
  # 
  #   cellFrame.origin.x += 2;
  # 
  #   NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName,textColor,NSForegroundColorAttributeName,nil]; 
  #   [stringValue drawInRect:cellFrame withAttributes:attributes];
  # }
  
  # not tested myself!
  
  def drawInteriorWithFrame_inview(cellFrame, controlView)
    textColor = nil
    if self.state == OSX::NSOnState
      OSX::NSColor.lightGrayColor.set
      OSX::NSRectFill cellFrame
      textColor = OSX::NSColor.whiteColor
    else
      textColor = OSX::NSColor.blackColor
    end
    cellFrame.origin.x += 2
    attributes = { OSX::NSFontAttributeName => self.font, OSX::NSForegroundColorAttributeName => textColor }
    self.title.drawInRect_withAttributes(cellFrame, attributes)
  end
  
end
