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
    
    delegate_mock = mock('Delegate')
    @backend.delegate = delegate_mock
  end
  
  it "should start the backend" do
    backend = Backend.alloc
    backend.expects(:kill_running_backend_process)
    backend.expects(:check_if_index_file_exists)
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
  
  def stub_index_file_exist(return_value)
    File.stubs(:exist?).with(File.expand_path("~/Library/Application Support/Kari/index.marshal")).returns(return_value)
  end
  
  it "should check if the index file already exists" do
    stub_index_file_exist(false)
    @backend.check_if_index_file_exists
    @backend.first_run?.should.be true
    
    stub_index_file_exist(true)
    @backend.check_if_index_file_exists
    @backend.first_run?.should.be false
  end
  
  it "should not give the started backend signal if the socket can't connect to the backend" do
    TCPSocket.expects(:new).raises Errno::ECONNREFUSED
    @backend.checkIfBackendStarted(nil)
  end
  
  it "should give the started signal if the socket can connect to the backend" do
    socket_mock = mock('Socket')
    TCPSocket.stubs(:new).returns(socket_mock)
    socket_mock.stubs(:close)
    
    timer_mock = mock('Timer')
    timer_mock.expects(:invalidate)
    
    @backend.expects(:backendDidStart)
    
    @backend.checkIfBackendStarted(timer_mock)
  end
  
  it "should pass the started signal on to the delegate if the index file already exists." do
    @backend.expects(:first_run?).returns(false)
    @backend.delegate.expects(:backendDidStart).with(@backend)
    @backend.backendDidStart
  end
  
  it "should pass the building index signal on to the delegate if the index file didn't already exist" do
    @backend.expects(:first_run?).returns(true)
    @backend.delegate.expects(:backendDidStartFirstIndexing).with(@backend)
    OSX::NSTimer.expects(:scheduledTimerWithTimeInterval_target_selector_userInfo_repeats).with(0.5, @backend, :checkIfFirstIndexFinished, nil, true)
    @backend.backendDidStart
  end
  
  it "should not pass the started signal to the delegate if the status of the first index build is not 'done'" do
    Net::HTTP.expects(:get).with('127.0.0.1', '/status', @port).returns('blablabla<title>building</title>blablabla')
    @backend.checkIfFirstIndexFinished(nil)
  end
  
  it "should pass the started signal on to the delegate if the status of the first index build is 'done'" do
    Net::HTTP.expects(:get).with('127.0.0.1', '/status', @port).returns('blablabla<title>ready</title>blablabla')
    timer_mock = mock('Timer')
    timer_mock.expects(:invalidate)
    @backend.delegate.expects(:backendDidStart).with(@backend)
    @backend.checkIfFirstIndexFinished(timer_mock)
  end
  
  # 
  # it "should check if the index exists, if not change the status message and poll the backend" do
  #   delegate_mock = mock('Delegate')
  #   @backend.delegate = delegate_mock
  #   
  #   socket_mock = mock('Socket')
  #   TCPSocket.stubs(:new).returns(socket_mock)
  #   socket_mock.stubs(:close)
  #   
  #   File.expects(:exist?).with(File.expand_path("~/Library/Application Support/Kari/index.marshal")).returns(false)
  #   #delegate_mock.expects(:buildingIndex)
  #   
  #   delegate_mock.expects(:backendDidStart).with(@backend)
  #   
  #   timer_mock = mock('Timer')
  #   timer_mock.stubs(:invalidate)
  #   @backend.checkIfBackendStarted(timer_mock)
  # end
end
