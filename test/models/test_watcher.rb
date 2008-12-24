require File.expand_path('../../test_helper', __FILE__)

describe "Watcher" do
  include TemporaryApplicationSupportPath
  
  it "should start watching the RI paths after intialization" do
    Rucola::FSEvents.expects(:start_watching)
    Watcher.new
  end
  
  it "should not start watching the RI paths after initialization if told not to" do
    Rucola::FSEvents.expects(:start_watching).never
    Watcher.new(:watch_fs_events => false)
  end
end

describe "A Watcher" do
  include TemporaryApplicationSupportPath
  
  before do
    Rucola::FSEvents.stubs(:start_watching).returns(stub(:stop))
    @watcher = Watcher.new
  end
  
  after do
    @watcher.stop
    Manager.reset!
  end
  
  it "should have RI paths to index" do
    @watcher.riPaths.should.not.be.empty
  end
  
  it "should know which paths to watch for changes" do
    @watcher.watchPaths.sort.should == %w(/Library/Ruby/Gems/1.8/doc /System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/lib/ruby/gems/1.8/doc /System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/share/ri/1.8/system)
  end
  
  it "should have nil as default for the FSEvent ID" do
    @watcher.lastEventId.should.be.nil
  end
  
  it "should store the last FSEvent ID" do
    @watcher.setLastEventId(12)
    @watcher.lastEventId.should == 12
  end
  
  it "should handle events coming from FSEvents" do
    @watcher.expects(:runKaridocUpdateCommandWithPaths).with('/Library/Ruby/Gems/1.8/doc/nap-0.2/ri')
    @watcher.handleEvents(events)
  end
  
  it "should set the last event id as the last even id" do
    @watcher.stubs(:runKaridocUpdateCommandWithPaths)
    @watcher.expects(:setLastEventId).with(events.last.id)
    @watcher.handleEvents(events)
  end
  
  it "should be able to force a rebuild" do
    @watcher.expects(:runKaridocUpdateCommandWithPaths).with(@watcher.watchPaths)
    @watcher.forceRebuild
  end
  
  it "should be able to examine all RI paths" do
    @watcher.expects(:examine).with(@watcher.riPaths)
    @watcher.examineAll
  end
  
  it "should stop FSEvents for watcher when stopped" do
    @watcher.fsevents.expects(:stop).at_least(1)
    @watcher.stop
  end
  
  it "should contruct a correct command to issue to the shell" do
    Thread.stubs(:start).yields
    
    Kernel.expects(:system).with("#{@watcher.kariPath} update-karidoc '/bogus/path/1' '/bogus/path/2'")
    @watcher.runKaridocUpdateCommandWithPaths('/bogus/path/1', '/bogus/path/2')
  end
  
  it "should notify the delegate it started indexing if there is a delegate" do
    Thread.stubs(:start)
    Kernel.stubs(:system)
    
    controller = mock
    controller.stubs(:respond_to?).returns(true)
    controller.expects(:startedIndexing).with(@watcher)
    @watcher.delegate = controller
    
    @watcher.runKaridocUpdateCommandWithPaths
  end
  
  it "should not notify the delegate it started indexing if there is no delegate" do
    Thread.stubs(:start)
    Kernel.stubs(:system)
    
    lambda {
      @watcher.runKaridocUpdateCommandWithPaths
    }.should.not.raise(NoMethodError)
  end
  
  it "should notify the main application that it finished examining (distributed)" do
    OSX::NSDistributedNotificationCenter.defaultCenter.expects(:objc_send).with(
      :postNotificationName, 'KariDidFinishIndexing', :object, nil
    )
    @watcher.examine([])
  end
  
  protected
  
  def events
    [
      stub(:id => 234, :path => '/Library/Ruby/Gems/1.8/doc/nap-0.2/ri/REST/Request/perform-i.yaml'),
      stub(:id => 535, :path => '/Library/Ruby/Gems/1.8/doc/nap-0.2/ri/created.rid'),
      stub(:id => 540, :path => '/Library/Ruby/Gems/1.8/doc/nap-0.2/ri/REST/cdesc-REST.yaml'),
      stub(:id => 541, :path => '/Library/Ruby/Gems/1.8/doc/nap-0.2/ri/REST/Response/new-c.yaml')
    ]
  end
end