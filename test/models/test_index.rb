require File.expand_path('../../test_helper', __FILE__)

describe "Index" do
  before do
    OSX.stubs(:NSHomeDirectory).returns(File.join(TEST_ROOT, 'fixtures'))
  end
  
  it "should initialize from marshaled disk image" do
    index = Index.initialize_from_disk
    index.length.should == 0
  end
end

describe "An Index" do
  before do
    OSX.stubs(:NSHomeDirectory).returns(File.join(TEST_ROOT, 'fixtures'))
    @index = Index.new
    @index.read_from_disk
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
  
  it "should merge ri descriptions from a directory" do
    @index.examine(File.join(TEST_ROOT, 'fixtures', 'ri'))
    @index.definitions.has_key?('Binding').should == true
    @index.tree.has_key?('Binding').should == true
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
end
