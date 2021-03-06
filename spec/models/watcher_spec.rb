require File.expand_path('../../spec_helper', __FILE__)

describe "Watcher" do
  extend TemporaryApplicationSupportPath
  
  it "should calculate the union between two paths" do
    Watcher.union('', '').should == '/'
    Watcher.union('/', '/').should == '/'
    Watcher.union('/Library/Ruby', '/Library/Ruby').should == '/Library/Ruby'
    Watcher.union('/Library/Ruby/1', '/Library/Ruby/2').should == '/Library/Ruby'
    Watcher.union('/System/Frameworks/Ruby/Current/Doc', '/Library/Ruby/1').should == '/'
    Watcher.union('/System/Frameworks/Ruby/Current/Doc', '/System/Frameworks/MacRuby/Doc').should == '/System/Frameworks'
  end
  
  it "should calculate basePaths for a list of paths" do
    Watcher.basePaths([]).should == []
    Watcher.basePaths(['/Library/Ruby']).should == ['/Library/Ruby']
    Watcher.basePaths(['/Library/Ruby/1', '/Library/Ruby/2']).should == ['/Library/Ruby']
    Watcher.basePaths(['/System/Frameworks/Ruby/Current/Doc', '/Library/Ruby/1', '/Library/Ruby/2']).should == ['/System/Frameworks/Ruby/Current/Doc', '/Library/Ruby', ]
    Watcher.basePaths(['/', '/Library/Ruby/1', '/Library/Ruby/2', '/tmp/something']).should == ["/Library/Ruby", "/tmp/something"]
  end
  
  it "should empty the queue during init" do
    watcher = Watcher.alloc
    watcher.stubs(:super_init).returns(watcher)
    watcher.init
    watcher.examineQueue.should.be.empty?
  end
end

module WatcherHelper
  def events
    [
      stub(:id => NSNumber.numberWithInt(234), :path => '/Library/Ruby/Gems/1.8/doc/nap-0.2/ri/REST/Request/perform-i.yaml'),
      stub(:id => NSNumber.numberWithInt(535), :path => '/Library/Ruby/Gems/1.8/doc/nap-0.2/ri/created.rid'),
      stub(:id => NSNumber.numberWithInt(540), :path => '/Library/Ruby/Gems/1.8/doc/nap-0.2/ri/REST/cdesc-REST.yaml'),
      stub(:id => NSNumber.numberWithInt(541), :path => '/Library/Ruby/Gems/1.8/doc/nap-0.2/ri/REST/Response/new-c.yaml')
    ]
  end
  
  def task_allocation_stub
    task = stub(
      :environment= => nil,
      :launchPath= => nil,
      :arguments= => nil,
      :launch => nil
    )
    task.stubs(:init).returns(task)
    NSTask.stubs(:alloc).returns(task)
    task
  end
  
  def expect_task_configured_and_launched
    paths = ["/Library/Ruby/Gems/1.8/doc/nap-0.2/ri"]
    task  = stub(:isRunning => true)
    
    Manager.stubs(:next_filepath).returns(next_filepath = '/path/to/next')
    @watcher.expects(:execute).with('update', '--current-karidoc', Manager.instance.filepath, '--next-karidoc', next_filepath, *paths).returns(task)
    
    paths
  end
end

describe "A Watcher" do
  extend TemporaryApplicationSupportPath
  extend WatcherHelper
  
  before do
    @watcher = Watcher.alloc
    @watcher.stubs(:super_init).returns(@watcher)
    @watcher.stubs(:synchronize).yields
    @watcher.init
    
    @watcher.stubs(:execute)
  end
  
  after do
    @watcher.stop
  end
  
  it "should know the path to the kari commandline utility" do
    @watcher.kariPath.should.start_with?(Kari.root_path)
    @watcher.kariPath.should.end_with?('kari')
  end
  
  it "should know the environment for the kari task" do
    @watcher.kariEnvironment.keys.should.include('KARI_ROOT')
    @watcher.kariEnvironment.keys.should.include('KARI_ENV')
    @watcher.kariEnvironment.keys.should.include('HOME')
  end
  
  it "should know which paths to watch" do
    @watcher.watchPaths.length.should == 1
  end
  
  it "should know all the ri paths on the system" do
    (@watcher.riPaths - @watcher.watchPaths).length.should == 2
    @watcher.riPaths.length.should == 2
  end
  
  it "should start watching the watchPaths when started" do
    watchPaths = ['/path/to/nowhere', '/path/to/ri']
    @watcher.stubs(:watchPaths).returns(watchPaths)
    
    FSEvents.expects(:start_watching).with(watchPaths, :since => nil, :latency => 5.0).returns(stub(:stop))
    @watcher.start
  end
  
  it "should stop watching the watchPaths when stopped" do
    @watcher.fsevents = mock()
    # Mocha gets confused when the after block calls stop too
    @watcher.fsevents.expects(:stop).at_least(1)
    @watcher.stop
  end
  
  it "should know the lastEventId" do
    @watcher.lastEventId.should.be.nil
    @watcher.setLastEventId(NSNumber.numberWithInt(34123))
    @watcher.lastEventId.should == 34123
    @watcher.setLastEventId(NSNumber.numberWithInt(34140))
    @watcher.lastEventId.should == 34140
  end
  
  it "should append paths to the examineQueue" do
    @watcher.stubs(:signal)
    path = '/path/to/ri'
    
    @watcher << [path]
    @watcher.examineQueue.last.should == path
  end
  
  it "should send a signal to itself when something is added to the examineQueue" do
    @watcher.expects(:signal)
    @watcher << ['/path/to/ri']
  end
  
  it "should handle events generated by FSEvents" do
    @watcher.stubs(:signal)
    @watcher.handleEvents(events)
    
    @watcher.examineQueue.should == ["/Library/Ruby/Gems/1.8/doc/nap-0.2/ri"]
    @watcher.lastEventId.should == 541
  end
  
  it "should handle an empty event list" do
    @watcher.stubs(:signal)
    @watcher.expects(:<<).never
    @watcher.expects(:setLastEventId).never
    @watcher.handleEvents([])
  end
  
  it "should start a new task when signalled and having no task yet" do
    paths = expect_task_configured_and_launched
    @watcher << paths
  end
  
  it "should start a new task when signalled and having no running task" do
    @watcher.task = mock(:isRunning => false)
    paths = expect_task_configured_and_launched
    @watcher << paths
  end
  
  it "should not start a new task when there is still a task running" do
    @watcher.task = stub(:isRunning => true)
    NSTask.expects(:alloc).never
    @watcher << ['/path/to/ri']
  end
  
  it "should notify the delegate that it started updating documentation" do
    @watcher.task = stub(:isRunning => false)
    @watcher.stubs(:update)
    
    @watcher.delegate = stub
    @watcher.delegate.expects(:startedIndexing).with(@watcher)
    @watcher.delegate.stubs(:finishedIndexing)
    
    @watcher << ['/path/to/ri']
  end
  
  it "should notify the delegate that it finished updating documentation" do
    @watcher.task = stub(:isRunning => false)
    @watcher.stubs(:update)
    
    @watcher.delegate = stub
    @watcher.delegate.stubs(:startedIndexing)
    @watcher.delegate.expects(:finishedIndexing).with(@watcher)
    
    @watcher << ['/path/to/ri']
  end
  
  it "should notify the delegate that it finished updating documentation when there is a current task" do
    @watcher.task = stub(:isRunning => false)
    @watcher.stubs(:update)
    
    @watcher.delegate = stub
    @watcher.delegate.stubs(:startedIndexing)
    @watcher.delegate.expects(:finishedIndexing).with(@watcher)
    
    @watcher << ['/path/to/ri']
  end
  
  it "should not notify the delegate that it finished updating documentation when there is no current task" do
    @watcher.stubs(:update)
    
    @watcher.delegate = stub
    @watcher.delegate.stubs(:startedIndexing)
    @watcher.delegate.expects(:finishedIndexing).never
    
    @watcher << ['/path/to/ri']
  end
  
  it "should queue all the riPaths when a rebuild is forced" do
    @watcher.expects(:<<).with(@watcher.riPaths)
    @watcher.forceRebuild
  end
  
  it "should empty it's queue when asked" do
    @watcher.stubs(:signal)
    
    @watcher << ['/path/to/ri']
    @watcher.examineQueue.should.not.be.empty
    @watcher.emptyQueue
    @watcher.examineQueue.should.be.empty
  end
end