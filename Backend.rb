require 'osx/cocoa'
require "socket"
require 'net/http'
require File.expand_path("../free_tcp_port", __FILE__)

class Backend < OSX::NSObject
  attr_accessor :delegate
  attr_reader :port
  
  def init
    if super_init
      # quit any already running process
      kill_running_backend_process
      
      # First time? Check before we launch the backend,
      # otherwise it creates the file and we can't check
      # if it's the first time anymore
      check_if_index_file_exists
      
      @port = FreeTCPPort.find(:start_from => 10002)
      puts "Free TCP port found: #{@port}" if $KARI_DEBUG
      
      libdir = $KARI_DEBUG ? File.expand_path('../../../../../lib', File.dirname(__FILE__)) : File.expand_path('lib', File.dirname(__FILE__))
      puts "Backend libdir: #{libdir}" if $KARI_DEBUG
      
      @backend = OSX::NSTask.alloc.init
      @backend.launchPath = '/usr/bin/env'
      @backend.arguments = ['ruby', File.join(libdir, 'server.rb'), '--port', @port.to_s]
      @backend.currentDirectoryPath = libdir
      @backend.environment = { 'HOME' => ENV['HOME'], 'KARI_DEBUG' => $KARI_DEBUG.to_s }

      return self
    end
  end
  
  def kill_running_backend_process
    # this should be done through a http `quit` request instead of using kill.
    if last_process = OSX::NSUserDefaults.standardUserDefaults['LastBackendProcess']
      Thread.new(last_process) do |last_process|
        running_pid = `lsof -i tcp:#{last_process['port']} | awk '{ if ( NR > 1 ) print $2 }'`.to_i
        if last_process['pid'] == running_pid
          `kill #{running_pid}`
        end
      end
    end
  end
  
  def check_if_index_file_exists
    @index_file_exists = File.exist?(File.expand_path("~/Library/Application Support/Kari/index.marshal"))
  end
  
  def first_run?
    !@index_file_exists
  end
  
  def checkIfBackendStarted(timer)
    begin
      TCPSocket.new('localhost', @port).close
      timer.invalidate
      self.backendDidStart
    rescue Errno::ECONNREFUSED
    end
  end
  
  def backendDidStart
    if first_run?
      @delegate.backendDidStartFirstIndexing(self)
      OSX::NSTimer.scheduledTimerWithTimeInterval_target_selector_userInfo_repeats(0.5, self, :checkIfFirstIndexFinished, nil, true)
    else
      @delegate.backendDidStart(self)
    end
  end
  
  def checkIfFirstIndexFinished(timer)
    if Net::HTTP.get('127.0.0.1', '/status', @port).include? '<title>ready</title>'
      timer.invalidate
      @delegate.backendDidStart(self)
    end
  end
  
  def launch
    OSX::NSTimer.scheduledTimerWithTimeInterval_target_selector_userInfo_repeats(0.5, self, :checkIfBackendStarted, nil, true)
    @backend.launch
    OSX::NSUserDefaults.standardUserDefaults['LastBackendProcess'] = { 'port' => @port, 'pid' => @backend.processIdentifier }
  end
  
  def running?
    @backend.isRunning
  end
  
  def terminate
    @backend.terminate
  end
end
