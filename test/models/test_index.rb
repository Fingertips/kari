require File.expand_path('../../test_helper', __FILE__)

PRIMARY_RI_PATH = File.join(TEST_ROOT, 'fixtures', 'ri')
ALTERNATE_RI_PATH = File.join(TEST_ROOT, 'fixtures', 'alternate-ri')

describe "Index" do
  before do
    Index.any_instance.stubs(:filepath).returns(Dir::tmpdir)
    OSX.stubs(:NSHomeDirectory).returns(File.join(TEST_ROOT, 'fixtures'))
  end
  
  it "should initialize from marshaled disk image" do
    index = Index.initialize_from_disk
    index.length.should == 3
    index.close
  end
end

describe "An empty Index" do
  before do
    Index.any_instance.stubs(:filepath).returns(Dir::tmpdir)
    OSX.stubs(:NSHomeDirectory).returns(File.join(TEST_ROOT, 'fixtures'))
    @index = Index.new
  end
  
  after do
    @index.close
  end
  
  it "should return the number of indexed entries" do
    @index.length.should == 0
  end
  
  it "should write the current index to disk" do
    @index.stubs(:filepath).returns(Dir::tmpdir)
    @index.write_to_disk
    @index.should.exist
    File.unlink(@index.filename)
  end
  
  it "should add definitions to the tree" do
    @index.add_karidoc_to_tree('Module::Class#method')
    @index.add_karidoc_to_tree('Module::Class::classmethod')
    @index.add_karidoc_to_tree('Module2::Class#othermethod')
    @index.tree.empty?.should == false
    @index.tree.get(%w(Module Class method)).should.not.be.nil
  end
  
  it "should add definition to the index" do
    @index.add_definition('Module::Class#method', 'path/to/file_1.yaml')
    @index.add_definition('Module::Class::classmethod', 'path/to/file_2.yaml')
    @index.add_definition('Module::Class::classmethod', 'path/to/file_3.yaml')
    @index.definitions["Module::Class#method"].length.should == 1
    @index.definitions["Module::Class::classmethod"].length.should == 2
  end
  
  it "should add definitions found in definition files" do
    @index.examine(PRIMARY_RI_PATH)
    
    @index.definitions.has_key?('Binding').should == true
    @index.tree.get(%w(Binding dup)).should.not.be.nil
    
    @index.definitions.length.should == 3
    @index.definitions["Binding#dup"].length.should == 1
    @index.definitions["Binding#clone"].length.should == 1
  end
  
  it "should merge multiple definitions" do
    @index.examine(PRIMARY_RI_PATH)
    @index.examine(ALTERNATE_RI_PATH)
    
    @index.definitions.length.should == 3
    @index.definitions["Binding#dup"].length.should == 2
    @index.definitions["Binding#clone"].length.should == 1
  end
end

describe "A filled Index" do
  before do
    Index.any_instance.stubs(:filepath).returns(Dir::tmpdir)
    OSX.stubs(:NSHomeDirectory).returns(File.join(TEST_ROOT, 'fixtures'))
    
    @index = Index.new
    @index.examine(PRIMARY_RI_PATH)
  end
  
  after do
    @index.close
    FileUtils.rm_rf(@index.filepath)
  end
  
  it "should remove definitions when removed from the filesystem" do
    File.stubs(:exist?).returns(false)
    @index.purge_vanished(PRIMARY_RI_PATH)
    
    @index.definitions['Binding'].should.be.nil
    @index.definitions['Binding#clone'].should.be.nil
    @index.definitions['Binding#dub'].should.be.nil
    
    @index.tree.get(%w(Binding)).should.be.nil
    @index.tree.get(%w(Binding clone)).should.be.nil
    @index.tree.get(%w(Binding dup)).should.be.nil
  end
  
  it "should not remove definitions when an alternate definitions still exists" do
    @index.merge_new(ALTERNATE_RI_PATH)
    File.stubs(:exist?).returns(false)
    @index.purge_vanished(PRIMARY_RI_PATH)
    
    @index.definitions['Binding'].should.not.be.nil
    @index.definitions['Binding#dup'].should.not.be.nil
    @index.definitions['Binding#clone'].should.be.nil
    
    @index.tree.get(%w(Binding)).should.not.be.nil
    @index.tree.get(%w(Binding clone)).should.be.nil
    @index.tree.get(%w(Binding dup)).should.not.be.nil
  end
  
  it "should be able to write index to disk and read it back" do
    @index.write_to_disk
    @index.close
    
    index_from_disk = Index.initialize_from_disk
    index_from_disk.definitions.should == @index.definitions
    index_from_disk.tree.should == @index.tree
  end
end