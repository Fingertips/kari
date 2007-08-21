require 'osx/cocoa'

class Backend
  def initialize(port=nil)
    libdir = $KARI_DEBUG ? File.expand_path('../../../../../lib', File.dirname(__FILE__)) : File.expand_path('lib', File.dirname(__FILE__))
    puts "Backend libdir: #{libdir}" if $KARI_DEBUG
    
    @backend = OSX::NSTask.alloc.init
    @backend.launchPath = '/usr/bin/env'
    @backend.arguments = ['ruby', File.join(libdir, 'server.rb')]
    @backend.arguments << "--port #{port}" unless port.nil?
    @backend.currentDirectoryPath = libdir
    @backend.environment = { 'PATH' => ENV['PATH'], 'HOME' => ENV['HOME'] }
  end
  
  def launch
    @backend.launch
  end
  
  def running?
    @backend.isRunning
  end
  
  def terminate
    @backend.terminate
  end
end
