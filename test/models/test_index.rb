require File.expand_path('../../test_helper', __FILE__)

describe "Index" do
  xit "should initialize from marshaled disk image" do
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
  
  xit "should write the current index to disk" do
  end
end
