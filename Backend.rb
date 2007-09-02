require 'osx/cocoa'
require "socket"

class Backend < OSX::NSObject
  attr_accessor :delegate
  
  def init
    if super_init
      libdir = $KARI_DEBUG ? File.expand_path('../../../../../lib', File.dirname(__FILE__)) : File.expand_path('lib', File.dirname(__FILE__))
      puts "Backend libdir: #{libdir}" if $KARI_DEBUG
    
      @backend = OSX::NSTask.alloc.init
      @backend.launchPath = '/usr/bin/env'
      @backend.arguments = ['ruby', File.join(libdir, 'server.rb')]
      port = nil
      @backend.arguments << "--port #{port}" unless port.nil?
      @backend.currentDirectoryPath = libdir
      @backend.environment = { 'PATH' => '/opt/local/bin', 'HOME' => ENV['HOME'] }
      
      return self
    end
  end
  
  def checkIfBackendStarted(timer)
    begin
      TCPSocket.new('localhost', 9999)
      timer.invalidate
      @delegate.backendDidStart(self)
    rescue
    end
  end
  
  def launch
    OSX::NSTimer.scheduledTimerWithTimeInterval_target_selector_userInfo_repeats(0.5, self, 'checkIfBackendStarted:', nil, true)
    @backend.launch
  end
  
  def running?
    @backend.isRunning
  end
  
  def terminate
    @backend.terminate
  end
end
