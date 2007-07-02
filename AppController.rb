#
#  AppController.rb
#  Kari
#
#  Created by Eloy Duran on 7/2/07.
#  Copyright (c) 2007 __MyCompanyName__. All rights reserved.
#

require 'osx/cocoa'
require "CampKari"
OSX.require_framework 'WebKit'

class AppController < OSX::NSObject
  ib_outlets :webView
  
  def init
    if super_init
      @camp_kari = CampKari.new
      @camp_kari.launch
      
      OSX::NSApplication.sharedApplication.setDelegate(self)
      return self
    end
  end
  
  def applicationWillTerminate(aNotification)
    puts 'quit'
    @camp_kari.terminate
  end
  
end
