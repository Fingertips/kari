require File.expand_path('../../test_helper', __FILE__)

PRIMARY_RI_PATH = File.join(TEST_ROOT, 'fixtures', 'ri')
ALTERNATE_RI_PATH = File.join(TEST_ROOT, 'fixtures', 'alternate-ri')

describe "Manager" do
  before do
    Manager.any_instance.stubs(:filepath).returns(Dir::tmpdir)
    OSX.stubs(:NSHomeDirectory).returns(File.join(TEST_ROOT, 'fixtures'))
  end
  
  it "should initialize from marshaled disk image" do
    index = Manager.initialize_from_disk
    index.length.should == 3
    index.close
  end
end

describe "An empty Manager" do
  before do
    Manager.any_instance.stubs(:filepath).returns(Dir::tmpdir)
    OSX.stubs(:NSHomeDirectory).returns(File.join(TEST_ROOT, 'fixtures'))
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
    
    @manager.definitions.length.should == 3
    @manager.definitions["Binding#dup"].length.should == 1
    @manager.definitions["Binding#clone"].length.should == 1
  end
  
  it "should merge multiple definitions" do
    @manager.examine(PRIMARY_RI_PATH)
    @manager.examine(ALTERNATE_RI_PATH)
    
    @manager.definitions.length.should == 3
    @manager.definitions["Binding#dup"].length.should == 2
    @manager.definitions["Binding#clone"].length.should == 1
  end
end

describe "A filled Manager" do
  before do
    Manager.any_instance.stubs(:filepath).returns(Dir::tmpdir)
    OSX.stubs(:NSHomeDirectory).returns(File.join(TEST_ROOT, 'fixtures'))
    
    @manager = Manager.new
    @manager.examine(PRIMARY_RI_PATH)
  end
  
  after do
    @manager.close
    FileUtils.rm_rf(@manager.filepath)
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
  
  it "should be able to write index to disk and read it back" do
    @manager.write_to_disk
    @manager.close
    
    index_from_disk = Manager.initialize_from_disk
    index_from_disk.definitions.should == @manager.definitions
    index_from_disk.namespace.should == @manager.namespace
  end
end