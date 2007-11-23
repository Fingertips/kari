require 'rubygems'
require 'test/unit'
require 'test/spec'
require 'mocha'

require File.dirname(File.expand_path(__FILE__)) + "/../Backend.rb"

def OSX._ignore_ns_override; true; end

# class Backend
#   def self.setTheReturnMock(mock)
#     @theReturnMock = mock
#   end
#   def init
#     @theReturnMock
#   end
# end

describe 'Backend' do
  before do
    @port = 54321
    FreeTCPPort.stubs(:find).returns(@port)
    @pid = 12345
    @backend = Backend.alloc.init
  end
  
  it "should start the backend in a separate process" do
    backend = Backend.alloc
    backend.expects(:kill_running_backend_process)
    
    backend.init
  end
  
  it "should write the pid and port to the prefs after launching the backend process" do
    task = @backend.instance_variable_get(:@backend)
    task.expects(:launch)
    task.expects(:processIdentifier).returns(12345)
    
    OSX::NSUserDefaults.standardUserDefaults.expects(:[]=).with('LastBackendProcess', {'port' => @port, 'pid' => @pid})
    
    @backend.launch
  end
  
  # it "should check if the last process is still running and kill it" do
  #   OSX::NSUserDefaults.standardUserDefaults.expects(:[]).with('LastBackendProcess').returns({'port' => @port, 'pid' => @pid})
  #   Kernel.expects(:system).with("lsof -i tcp:#{@port} | awk '{ if ( NR > 1 ) print $2 }'").returns("#{@pid}\n")
  #   Kernel.expects(:system).with("kill #{@pid}")
  #   @backend.kill_running_backend_process
  # end
end