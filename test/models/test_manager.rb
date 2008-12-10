require File.expand_path('../../test_helper', __FILE__)

PRIMARY_RI_PATH = File.join(TEST_ROOT, 'fixtures', 'normal', 'ri')
ALTERNATE_RI_PATH = File.join(TEST_ROOT, 'fixtures', 'alternate', 'ri')

describe "Manager" do
  include TemporaryApplicationSupportPath
  
  it "should initialize from marshaled disk image" do
    index = Manager.initialize_from_disk
    index.length.should == 0
    index.close
  end
  
  it "should always return the same singleton instance" do
    remove_manager_singleton!
    
    manager = mock('Manager')
    Manager.expects(:initialize_from_disk).once.returns(manager)
    Manager.instance.should.be manager
    Manager.instance.should.be manager
    
    remove_manager_singleton!
  end
  
  private
  
  def remove_manager_singleton!
    Manager.instance_variable_set(:@instance, nil)
  end
end

describe "A Manager" do
  include TemporaryApplicationSupportPath
  
  before do
    @manager = Manager.new
  end
  
  after do
    @manager.close
  end
  
  it "should not break when RI has descriptions with an empty full name (workaround for a bug)" do
    lambda {
      @manager.add('', '/path/to/cdesc-.yml')
      @manager.add('#JSON', '/path/to/JSON/JSON-i.yml')
    }.should.not.raise
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
  
  it "should add descriptions to the.namespace" do
    @manager.add_karidoc_to_namespace('Module::Class#method')
    @manager.add_karidoc_to_namespace('Module::Class::classmethod')
    @manager.add_karidoc_to_namespace('Module2::Class#othermethod')
    @manager.namespace.empty?.should == false
    @manager.namespace.get(%w(Module Class method)).should.not.be.nil
  end
  
  it "should add description to the index" do
    @manager.add_description('Module::Class#method', 'path/to/file_1.yaml')
    @manager.add_description('Module::Class::classmethod', 'path/to/file_2.yaml')
    @manager.add_description('Module::Class::classmethod', 'path/to/file_3.yaml')
    @manager.descriptions["Module::Class#method"].length.should == 1
    @manager.descriptions["Module::Class::classmethod"].length.should == 2
  end
  
  it "should add descriptions found in description files" do
    @manager.examine(PRIMARY_RI_PATH)
    
    @manager.descriptions.has_key?('Binding').should == true
    @manager.namespace.get(%w(Binding dup)).should.not.be.nil
    
    @manager.descriptions.length.should == 11
    @manager.descriptions["Binding#dup"].length.should == 1
    @manager.descriptions["Binding#clone"].length.should == 1
  end
  
  it "should merge multiple descriptions" do
    @manager.examine(PRIMARY_RI_PATH)
    @manager.examine(ALTERNATE_RI_PATH)
    
    @manager.descriptions.length.should == 11
    @manager.descriptions["Binding#dup"].length.should == 2
    @manager.descriptions["Binding#clone"].length.should == 1
  end
  
  it "should add new descriptions for classes" do
    @manager.add('Binding', file_fixture('normal', 'ri', 'Binding', 'cdesc-Binding.yaml'))
    @manager.descriptions['Binding'].should.not.be.nil
    @manager.namespace.get(['Binding']).should.not.be.nil
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
  
  it "should remove descriptions when removed from the filesystem" do
    File.stubs(:exist?).returns(false)
    @manager.purge_vanished(PRIMARY_RI_PATH)
    
    @manager.descriptions['Binding'].should.be.nil
    @manager.descriptions['Binding#clone'].should.be.nil
    @manager.descriptions['Binding#dub'].should.be.nil
    
    @manager.namespace.get(%w(Binding)).should.be.nil
    @manager.namespace.get(%w(Binding clone)).should.be.nil
    @manager.namespace.get(%w(Binding dup)).should.be.nil
  end
  
  it "should not remove descriptions when an alternate descriptions still exists" do
    @manager.merge_new(ALTERNATE_RI_PATH)
    File.stubs(:exist?).returns(false)
    @manager.purge_vanished(PRIMARY_RI_PATH)
    
    @manager.descriptions['Binding'].should.not.be.nil
    @manager.descriptions['Binding#dup'].should.not.be.nil
    @manager.descriptions['Binding#clone'].should.be.nil
    
    @manager.namespace.get(%w(Binding)).should.not.be.nil
    @manager.namespace.get(%w(Binding clone)).should.be.nil
    @manager.namespace.get(%w(Binding dup)).should.not.be.nil
  end
  
  it "should be able to write index to disk and read it back" do
    @manager.write_to_disk
    @manager.close
    
    @manager = Manager.initialize_from_disk
    @manager.descriptions.should == @manager.descriptions
    @manager.namespace.should == @manager.namespace
  end
end