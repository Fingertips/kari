#
#  AppController.rb
#  Kari
#
#  Created by Eloy Duran on 7/2/07.
#  Copyright (c) 2007 __MyCompanyName__. All rights reserved.
#

require 'osx/cocoa'
require "CampKari"

class AppController < OSX::NSObject
  
  def init
    if super_init
      @camp_kari = CampKari.alloc.init
      @camp_kari.launch
      
      OSX::NSApplication.sharedApplication.setDelegate(self)
      return self
    end
  end
  
end
