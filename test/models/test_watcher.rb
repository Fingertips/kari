require File.expand_path('../../test_helper', __FILE__)

describe "Watcher" do
  include TemporaryApplicationSupportPath
  
  it "should start watching the RI paths after intialization" do
    Rucola::FSEvents.expects(:start_watching)
    Watcher.new
  end
end

describe "A Watcher" do
  include TemporaryApplicationSupportPath
  
  before do
    @watcher = Watcher.new(:manager => Manager.new)
    OSX::NSNotificationCenter.defaultCenter.stubs(:postNotificationName_object)
  end
  
  after do
    @watcher.manager.close
    @watcher.stop
  end
  
  it "should have nil as default for the FSEvent ID " do
    @watcher.lastEventId.should.be.nil
  end
  
  it "should store the last FSEvent ID" do
    @watcher.setLastEventId(12)
    @watcher.lastEventId.should == 12
  end
  
  it "should build an index for all RI paths using the Manager" do
    Thread.stubs(:new).yields
    
    @watcher.riPaths.each do |path|
      @watcher.manager.expects(:examine).with(path)
    end
    
    @watcher.buildIndex
  end
  
  it "should write indices to file after examining RI paths using the Manager" do
    Thread.stubs(:new).yields
    @watcher.manager.stubs(:examine)
    
    @watcher.manager.expects(:write_to_disk)
    
    @watcher.buildIndex
  end
  
  it "should send a notification after examining RI paths using the Manager" do
    Thread.stubs(:new).yields
    @watcher.manager.stubs(:examine)
    
    OSX::NSNotificationCenter.defaultCenter.expects(:postNotificationName_object).with('KariDidFinishIndexingNotification', nil)
    
    @watcher.buildIndex
  end
  
  it "should stop FSEvents for watcher when stopped" do
    @watcher.fsevents.expects(:stop).at_least(1)
    @watcher.stop
  end
end