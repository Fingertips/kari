#
#  AppController.rb
#  Crasher
#
#  Created by Eloy Duran on 12-10-07.
#  Copyright (c) 2007 __MyCompanyName__. All rights reserved.
#

require 'osx/cocoa'

class AppController < OSX::NSObject
  def awakeFromNib
    # And check if there were any errors the last time.
    SACrashReporter.submit
    
  end
  
  def raiseRubyException(sender)
    raise "A random exception"
  end
end
