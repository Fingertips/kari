#
#  SAFilterButton.rb
#  FilterBarTest
#
#  Created by Eloy Duran on 7/4/07.
#  Copyright (c) 2007 __MyCompanyName__. All rights reserved.
#

require 'osx/cocoa'

class OSX::SAFilterButton < OSX::NSButton
  
  def initWithOS(osVersion)
    if self.init
      if osVersion >= 10.4
        self.cell = OSX::SAFilterButtonCell.alloc.init
        self.buttonType = OSX::NSPushOnPushOffButton
        self.bezelStyle = OSX::NSRecessedBezelStyle
      else
        self.cell = SAFilterButtonPreTigerCell.alloc.init
        self.buttonType = OSX::NSPushOnPushOffButton
        self.bordered = false
      end
      return self
    end
  end
  
  def mouseDown(theEvent)
    self.cell.mouseDown(theEvent) if self.cell.respond_to? :mouseDown 
    super_mouseDown(theEvent)
  end
  
end
