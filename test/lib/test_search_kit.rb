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
    @filenames = Dir[File.join(TEST_ROOT, 'fixtures/ri/**/*.*')]
  end
  
  after do
    @index.close
    File.unlink(@path)
  end
  
  it "should raise an error when trying to count documents on an invalid document" do
    lambda {
      @index.count
    }.should.raise(SearchKit::Exceptions::IndexError)
  end
  
  it "should know the number of documents in the index" do
    @filenames[0,3].each_with_index do |filename, index|
      @index.addDocument(filename)
    end
    @index.flush
    sleep 0.1
    @index.count.should == 3
    
    @filenames[0,3].each_with_index do |filename, index|
      @index.removeDocument(filename)
    end
    @index.flush
    sleep 0.1
    @index.count.should == 0
  end
  
  it "should be able to add documents to the index" do
    @index.addDocument(@filenames.first).should == true
    @index.flush
    @index.count.should == 1
  end
  
  it "should not care about adding a document twice" do
    @index.addDocument(@filenames.first).should == true
    @index.addDocument(@filenames.first).should == true
  end
  
  it "should be able to remove documents from the index" do
    @index.addDocument(@filenames.first)
    @index.removeDocument(@filenames.first).should == true
    @index.flush
    @index.count.should == 0
  end
  
  it "should not care about removing a document that doesn't exist" do
    @index.removeDocument('/does/not/exist').should == true
  end
  
  it "should compact the index" do
    @index.compact.should == true
  end
  
  it "should flush changes to the backing store" do
    @index.flush.should == true
  end
end