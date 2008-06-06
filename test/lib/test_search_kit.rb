require File.expand_path('../../test_helper', __FILE__)

describe "The SearchKit Index" do
  it "should create and close new index" do
    path = File.join(Dir.tmpdir, 'search_kit_index')
    
    index = SearchKit::Index.create(path)
    index.should.not.be.nil
    index.close
    
    File.unlink(path)
  end
  
  it "should open and close an existing index" do
    path = File.join(Dir.tmpdir, 'search_kit_index')
    
    index = SearchKit::Index.create(path)
    index.close
    
    index = SearchKit::Index.open(path)
    index.should.not.be.nil
    index.close
    
    File.unlink(path)
  end
  
  it "should allow block syntax for open" do
    path = File.join(Dir.tmpdir, 'search_kit_index')
    
    index = SearchKit::Index.create(path)
    index.close
    
    SearchKit::Index.open(path) do |index|
      index.kind_of?(SearchKit::Index).should == true
    end
    
    File.unlink(path)
  end
end

describe "A SearchKit Index" do
  before do
    @path = File.join(Dir.tmpdir, 'search_kit_index')
    @index = SearchKit::Index.create(@path)
  end
  
  after do
    @index.close
    File.unlink(@path)
  end
  
  it "should be able to add documents to the index" do
    @index.addDocument('/etc/hosts').should == true
  end
end