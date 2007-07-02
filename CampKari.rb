#
#  CampKari.rb
#  Kari
#
#  Created by Eloy Duran on 7/2/07.
#  Copyright (c) 2007 __MyCompanyName__. All rights reserved.
#

require 'osx/cocoa'

class CampKari < OSX::NSObject
  def init
    if super_init
      puts 'start camp kari'
      @camp_kari = OSX::NSTask.alloc.init
      @camp_kari.launchPath = '/opt/local/bin/camping'
      @camp_kari.currentDirectoryPath = '/Users/eloy/code/KLANTEN/Fingertips/Kari/design/proof_of_concept/'
      @camp_kari.arguments = ['kari.rb']
      @camp_kari.environment = { 'PATH' => '/opt/local/bin', 'HOME' => '/Users/eloy' }
      
      return self
    end
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
