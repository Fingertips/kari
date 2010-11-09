require File.expand_path('../../spec_helper', __FILE__)

describe "FSEventStream" do
  it "watches directories for changes with a delegate" do
    eventStream = FSEventStream.alloc.initWithPaths(['/tmp', '/tmp'], delegate:self)
    eventStream.should.be.kind_of?(FSEventStream)
    eventStream.delegate.should == self
  end
  
  it "watches directories for changes with a callback" do
    b = Proc.new{}
    eventStream = FSEventStream.alloc.initWithPaths(['/tmp', '/tmp'], onChanges:b)
    eventStream.should.be.kind_of?(FSEventStream)
    eventStream.callback.should == b
  end
end

class Receiver
  attr_accessor :status
  
  def initialize
    @status = :waiting
  end
  
  def handleEvents(events)
    @status = :called
  end
end

describe "An FSEventStream" do
  it "starts and stops watching directories" do
    eventStream = FSEventStream.alloc.initWithPaths([Dir.tmpdir], onChanges:Proc.new {})
    eventStream.start.should == 1
    eventStream.stop
  end
  
  # it "calls its callback on changes" do
  #   tmpdir = Dir.tmpdir
  #   receiver = Receiver.new
  #   
  #   eventStream = FSEventStream.alloc.initWithPaths([tmpdir], delegate:receiver)
  #   eventStream.start.should == 1
  #   
  #   filename = File.join(tmpdir, 'fsevents-test')
  #   FileUtils.rm_f(filename)
  #   FileUtils.touch(filename)
  #   File.should.exist(filename)
  #   
  #   # Busy wait for the block to run
  #   started = Time.now
  #   while (receiver.status == :waiting) and (Time.now - started) < 3
  #     sleep 0.1
  #   end
  #   
  #   receiver.status.should == :called
  #   eventStream.stop
  # end
end