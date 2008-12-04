require File.expand_path('../../test_helper', __FILE__)

PRIMARY_RI_PATH = File.join(TEST_ROOT, 'fixtures', 'ri')
ALTERNATE_RI_PATH = File.join(TEST_ROOT, 'fixtures', 'alternate-ri')

describe "Manager" do
  include TemporaryApplicationSupportPath
  
  it "should initialize from marshaled disk image" do
    index = Manager.initialize_from_disk
    index.length.should == 0
    index.close
  end
end

describe "An empty Manager" do
  include TemporaryApplicationSupportPath
  include FixtureHelpers
  
  before do
    @manager = Manager.new
  end
  
  after do
    @manager.close
  end
  
  it "should return the number of indexed entries" do
    @manager.length.should == 0
  end
  
  it "should write the current index to disk" do
    @manager.stubs(:filepath).returns(Dir::tmpdir)
    @manager.write_to_disk
    @manager.should.exist
    File.unlink(@manager.filename)
  end
  
  it "should add definitions to the.namespace" do
    @manager.add_karidoc_to_namespace('Module::Class#method')
    @manager.add_karidoc_to_namespace('Module::Class::classmethod')
    @manager.add_karidoc_to_namespace('Module2::Class#othermethod')
    @manager.namespace.empty?.should == false
    @manager.namespace.get(%w(Module Class method)).should.not.be.nil
  end
  
  it "should add definition to the index" do
    @manager.add_definition('Module::Class#method', 'path/to/file_1.yaml')
    @manager.add_definition('Module::Class::classmethod', 'path/to/file_2.yaml')
    @manager.add_definition('Module::Class::classmethod', 'path/to/file_3.yaml')
    @manager.definitions["Module::Class#method"].length.should == 1
    @manager.definitions["Module::Class::classmethod"].length.should == 2
  end
  
  it "should add definitions found in definition files" do
    @manager.examine(PRIMARY_RI_PATH)
    
    @manager.definitions.has_key?('Binding').should == true
    @manager.namespace.get(%w(Binding dup)).should.not.be.nil
    
    @manager.definitions.length.should == 11
    @manager.definitions["Binding#dup"].length.should == 1
    @manager.definitions["Binding#clone"].length.should == 1
  end
  
  it "should merge multiple definitions" do
    @manager.examine(PRIMARY_RI_PATH)
    @manager.examine(ALTERNATE_RI_PATH)
    
    @manager.definitions.length.should == 11
    @manager.definitions["Binding#dup"].length.should == 2
    @manager.definitions["Binding#clone"].length.should == 1
  end
  
  it "should add new definitions for classes" do
    @manager.search_index.expects(:addDocument).with(KaridocGenerator.filename('Binding'))
    
    @manager.add('Binding', file_fixture('ri', 'Binding', 'cdesc-Binding.yaml'))
    @manager.definitions['Binding'].should.not.be.nil
    @manager.namespace.get(['Binding']).should.not.be.nil
    File.should.exist(KaridocGenerator.filename('Binding'))
  end
end

describe "A filled Manager" do
  include TemporaryApplicationSupportPath
  
  before do
    @manager = Manager.new
    @manager.examine(PRIMARY_RI_PATH)
  end
  
  after do
    @manager.close
  end
  
  it "should remove definitions when removed from the filesystem" do
    File.stubs(:exist?).returns(false)
    @manager.purge_vanished(PRIMARY_RI_PATH)
    
    @manager.definitions['Binding'].should.be.nil
    @manager.definitions['Binding#clone'].should.be.nil
    @manager.definitions['Binding#dub'].should.be.nil
    
    @manager.namespace.get(%w(Binding)).should.be.nil
    @manager.namespace.get(%w(Binding clone)).should.be.nil
    @manager.namespace.get(%w(Binding dup)).should.be.nil
  end
  
  it "should not remove definitions when an alternate definitions still exists" do
    @manager.merge_new(ALTERNATE_RI_PATH)
    File.stubs(:exist?).returns(false)
    @manager.purge_vanished(PRIMARY_RI_PATH)
    
    @manager.definitions['Binding'].should.not.be.nil
    @manager.definitions['Binding#dup'].should.not.be.nil
    @manager.definitions['Binding#clone'].should.be.nil
    
    @manager.namespace.get(%w(Binding)).should.not.be.nil
    @manager.namespace.get(%w(Binding clone)).should.be.nil
    @manager.namespace.get(%w(Binding dup)).should.not.be.nil
  end
  
  it "should send a notification message when done merging" do
    OSX::NSNotificationCenter.defaultCenter.expects(:postNotificationName_object).with('KariDidFinishIndexingNotification', nil).times(2)
    @manager.merge_new(ALTERNATE_RI_PATH)
  end
  
  it "should be able to write index to disk and read it back" do
    @manager.write_to_disk
    @manager.close
    
    @manager = Manager.initialize_from_disk
    @manager.definitions.should == @manager.definitions
    @manager.namespace.should == @manager.namespace
  end
end