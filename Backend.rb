require 'osx/cocoa'
require "socket"
require "free_tcp_port"

class Backend < OSX::NSObject
  attr_accessor :delegate
  attr_reader :port
  
  def init
    if super_init
      @port = FreeTCPPort.find(:start_from => 10002)
      puts "Free TCP port found: #{@port}" if $KARI_DEBUG
      
      libdir = $KARI_DEBUG ? File.expand_path('../../../../../lib', File.dirname(__FILE__)) : File.expand_path('lib', File.dirname(__FILE__))
      puts "Backend libdir: #{libdir}" if $KARI_DEBUG
      
      @backend = OSX::NSTask.alloc.init
      @backend.launchPath = '/usr/bin/ruby'
      @backend.arguments = [File.join(libdir, 'server.rb'), '--port', @port.to_s]
      @backend.currentDirectoryPath = libdir
      @backend.environment = { 'HOME' => ENV['HOME'] }
      
      return self
    end
  end
  
  def checkIfBackendStarted(timer)
    begin
      TCPSocket.new('localhost', @port).close
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
