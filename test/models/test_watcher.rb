require File.expand_path('../../test_helper', __FILE__)

describe "Watcher" do
  include TemporaryApplicationSupportPath
  
  it "should start watching the RI paths after intialization" do
    OSX::NSUserDefaults.stubs(:standardUserDefaults).returns({})
    Rucola::FSEvents.expects(:start_watching)
    Watcher.new
  end
end

describe "A Watcher" do
  include TemporaryApplicationSupportPath
  
  before do
    @watcher = Watcher.new
    OSX::NSNotificationCenter.defaultCenter.stubs(:postNotificationName_object)
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
  
  it "should have nil as default for the FSEvent ID " do
    @watcher.lastEventId.should.be.nil
  end
  
  it "should store the last FSEvent ID" do
    @watcher.setLastEventId(12)
    @watcher.lastEventId.should == 12
  end
  
  it "should handle events coming from FSEvents" do
    @watcher.expects(:rebuild).with('/Library/Ruby/Gems/1.8/doc/nap-0.2/ri')
    @watcher.handleEvents(events)
  end
  
  it "should set the last event id as the last even id" do
    @watcher.stubs(:rebuild)
    @watcher.expects(:setLastEventId).with(events.last.id)
    @watcher.handleEvents(events)
  end
  
  it "should be able to force a rebuild" do
    @watcher.expects(:rebuild).with(@watcher.riPaths)
    @watcher.forceRebuild
  end
  
  it "should rebuild indices for paths using the manager" do
    paths = ['/Library/Ruby/Gems/1.8/doc/nap-0.2/ri', '/Library/Ruby/Gems/1.8/doc/nap-0.1/ri']
    paths.each do |path|
      Manager.instance.expects(:examine).with(path)
    end
    Manager.instance.expects(:write_to_disk).at_least(1)
    
    @watcher.rebuild(paths)
  end
  
  it "should notify about the start and end of indexing" do
    OSX::NSNotificationCenter.defaultCenter.expects(:postNotificationName_object).with('KariDidStartIndexingNotification', nil)
    OSX::NSNotificationCenter.defaultCenter.expects(:postNotificationName_object).with('KariDidFinishIndexingNotification', nil)
    
    @watcher.rebuild([])
  end
  
  it "should stop FSEvents for watcher when stopped" do
    @watcher.fsevents.expects(:stop).at_least(1)
    @watcher.stop
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