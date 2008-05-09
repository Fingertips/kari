require File.expand_path('../../test_helper', __FILE__)

PRIMARY_RI_PATH = File.join(TEST_ROOT, 'fixtures', 'ri')
ALTERNATE_RI_PATH = File.join(TEST_ROOT, 'fixtures', 'alternate-ri')

describe "Index" do
  before do
    OSX.stubs(:NSHomeDirectory).returns(File.join(TEST_ROOT, 'fixtures'))
  end
  
  it "should initialize from marshaled disk image" do
    index = Index.initialize_from_disk
    index.length.should == 0
  end
end

describe "An empty Index" do
  before do
    OSX.stubs(:NSHomeDirectory).returns(File.join(TEST_ROOT, 'fixtures'))
    @index = Index.new
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
    @index.add_definition_to_tree('Module::Class#method')
    @index.add_definition_to_tree('Module::Class::classmethod')
    @index.add_definition_to_tree('Module2::Class#othermethod')
    @index.tree.length.should == 2
    @index.tree['Module']['Class']['method'].should.not.be.nil
  end
  
  it "should add definition to the index" do
    @index.add_definition_to_index('Module::Class#method', 'path/to/file_1.yaml')
    @index.add_definition_to_index('Module::Class::classmethod', 'path/to/file_2.yaml')
    @index.add_definition_to_index('Module::Class::classmethod', 'path/to/file_3.yaml')
    @index.definitions.length.should == 2
    @index.definitions['Module::Class#method'].length.should == 1 
    @index.definitions['Module::Class::classmethod'].length.should == 2
  end
  
  it "should add definitions found in definition files" do
    @index.examine(PRIMARY_RI_PATH)
    
    @index.definitions.has_key?('Binding').should == true
    @index.tree.has_key?('Binding').should == true
    
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
    OSX.stubs(:NSHomeDirectory).returns(File.join(TEST_ROOT, 'fixtures'))
    @index = Index.new
    @index.examine(PRIMARY_RI_PATH)
  end
  
  it "should remove definitions when removed from the filesystem" do
    File.stubs(:exist?).returns(false)
    @index.purge_vanished(PRIMARY_RI_PATH)
    
    @index.definitions['Binding'].should.be.nil
    @index.definitions['Binding#clone'].should.be.nil
    @index.definitions['Binding#dub'].should.be.nil
    
    @index.tree['Binding'].should.be.nil
  end
  
  it "should not remove definitions when an alternate definitions still exists" do
    @index.merge_new(ALTERNATE_RI_PATH)
    File.stubs(:exist?).returns(false)
    @index.purge_vanished(PRIMARY_RI_PATH)
    
    @index.definitions['Binding'].should.not.be.nil
    @index.definitions['Binding#dup'].should.not.be.nil
    @index.definitions['Binding#clone'].should.be.nil
    
    @index.tree['Binding'].should.not.be.nil
    @index.tree['Binding']['dup'].should.not.be.nil
    @index.tree['Binding']['clone'].should.not.be.nil
  end
end