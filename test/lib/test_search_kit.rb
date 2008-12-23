require File.expand_path('../../test_helper', __FILE__)

describe "The SearchKit Index" do
  before do
    @path = File.join(Dir.tmpdir, 'search_kit_index')
    File.unlink(@path) rescue nil
  end
  
  after do
    File.unlink(@path) rescue nil
  end
  
  it "should create and close new index" do
    index = SearchKit::Index.create(@path)
    index.should.not.be.nil
    index.close
  end
  
  it "should open and close an existing index" do
    index = SearchKit::Index.create(@path)
    index.close
    
    index = SearchKit::Index.open(@path)
    index.should.not.be.nil
    index.close
  end
  
  it "should allow block syntax for open" do
    index = SearchKit::Index.create(@path)
    index.close
    
    SearchKit::Index.open(@path) do |index|
      index.kind_of?(SearchKit::Index).should == true
    end
  end
end

describe "A SearchKit Index" do
  include FixtureHelpers
  
  before do
    @path = File.join(Dir.tmpdir, 'search_kit_index')
    File.unlink(@path) rescue nil
    
    @index = SearchKit::Index.create(@path)
    @filenames = Dir[file_fixture('normal/ri/**/*.*')]
  end
  
  after do
    @index.close
    File.unlink(@path) rescue nil
  end
  
  it "should not raise an error when trying to count documents on an empty document" do
    lambda {
      @index.count
    }.should.not.raise
  end
  
  it "should know the number of documents in the index" do
    @index.count.should == 0
    
    @filenames[0,3].each_with_index do |filename, index|
      @index.addDocument(filename)
    end
    @index.flush
    @index.count.should == 3
    
    @filenames[0,3].each_with_index do |filename, index|
      @index.removeDocument(filename)
    end
    @index.flush
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
  
  it "should be able to add a document with a specified string to the index" do
    @index.addDocumentWithText(@filenames.first, 'The quick brown fox jumps over the lazy dog').should == true
    @index.flush
    @index.count.should == 1
    @index.search('fox').first.URL.path.should == @filenames.first
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
  
  it "should return an array of matches" do
    @filenames.each { |f| @index.addDocument(f) }
    @index.flush
    
    matches = @index.search('set_trace_func')
    matches.length.should.be 1
    match = matches.first
    
    match.should.be.an.instance_of SearchKit::Match
    match.URL.path.should == @filenames.find { |f| File.basename(f) == 'cdesc-Binding.yaml' }
    match.score.to_ruby.should.be.an.instance_of Float
  end
end

describe "A SearchKit Match" do
  include FixtureHelpers
  
  before do
    Rucola::RCApp.stubs(:application_support_path).returns(file_fixture('')[0..-2])
    @url = OSX::NSURL.fileURLWithPath(file_fixture('Karidoc', 'Mutex', 'try_lock.karidoc'))
    @score = 1.2345
    @match = SearchKit::Match.alloc.initWithURL_score(@url, @score)
  end
  
  it "should initialize with a document NSURL and relevance score" do
    @match.valueForKey('URL').path.should == @url.path
    @match.valueForKey('score').to_ruby.should == @score
  end
  
  it "should return the name of the matched class/method" do
    begin
      @match.valueForKey('name').should == 'Mutex::try_lock'
    rescue OSX::OCException
      @match.name.should == 'Mutex::try_lock'
    end
  end
end