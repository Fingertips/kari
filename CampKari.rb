#
#  CampKari.rb
#  Kari
#
#  Created by Eloy Duran on 7/2/07.
#  Copyright (c) 2007 __MyCompanyName__. All rights reserved.
#

require 'osx/cocoa'

class CampKari
  def initialize
    puts 'init camp kari'
    libdir = File.expand_path('lib/', File.dirname(__FILE__))
    @camp_kari = OSX::NSTask.alloc.init
    @camp_kari.launchPath = File.join(libdir, 'server.rb')
    @camp_kari.currentDirectoryPath = libdir
    @camp_kari.environment = { 'PATH' => ENV['PATH'], 'HOME' => ENV['HOME'] }
  end
  
  def launch
    @camp_kari.launch
  end
  
  def running?
    @camp_kari.isRunning
  end
  
  def terminate
    @camp_kari.terminate
  end
end
