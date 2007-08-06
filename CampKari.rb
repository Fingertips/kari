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
    libdir = $KARI_DEBUG ? File.expand_path('../../../../../lib/', File.dirname(__FILE__)) : File.expand_path('lib/', File.dirname(__FILE__))
    puts "Backend libdir: #{libdir}" if $KARI_DEBUG
    
    @camp_kari = OSX::NSTask.alloc.init
    @camp_kari.launchPath = '/usr/bin/env'
    @camp_kari.arguments = ['ruby', File.join(libdir, 'server.rb')]
    @camp_kari.currentDirectoryPath = libdir
    @camp_kari.environment = { 'PATH' => ENV['PATH'], 'HOME' => ENV['HOME'] }
    #@camp_kari.environment = { 'PATH' => '/opt/local/bin', 'HOME' => ENV['HOME'] }
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
