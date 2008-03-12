require File.expand_path('../../test_helper', __FILE__)

describe "Index" do
  it "should initialize from marshaled disk image" do
    index = Index.initialize_from_disk
    index.length.should == 0
  end
end

describe "An Index" do
  before do
    OSX.stubs(:NSHomeDirectory).returns(File.expand_path('../fixtures', __FILE__))
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
end
