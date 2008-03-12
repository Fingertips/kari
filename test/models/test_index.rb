require File.expand_path('../../test_helper', __FILE__)

describe "Index" do
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
  
  xit "should merge ri descriptions from a directory" do
    @index.examine(File.join(TEST_ROOT, 'fixtures', 'ri'))
  end
  
  xit "should merge definitions to the tree" do
    p @index.add_definition_to_tree('ActiveRecord::Base#id')
    p @index.add_definition_to_tree('ActiveRecord::Base#concat')
    p @index
  end
end
