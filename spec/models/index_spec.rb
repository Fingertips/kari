require File.expand_path('../../spec_helper', __FILE__)

# describe "Index" do
#   extend TemporaryApplicationSupportPath
#   
#   before do
#     FileUtils.mkdir_p(Kari.application_support_path)
#   end
#   
#   it "initializes" do
#     index = Index.alloc.init
#     index.should.be.kind_of?(Index)
#     index.index.should.be.nil
#   end
#   
#   it "creates at path" do
#     index = Index.createWithPath(File.join(Kari.application_support_path, 'SKIndex'))
#     index.should.be.kind_of?(Index)
#     index.index.should.not.be.nil
#   end
# end

describe "An Index, when loaded from disk" do
  extend TemporaryApplicationSupportPath
  extend FixtureHelpers
  
  before do
    FileUtils.mkdir_p(Kari.application_support_path)
    if (index = Index.createWithPath(File.join(Kari.application_support_path, 'SKIndex')))
      index.close
      @index = Index.alloc.initWithPath(File.join(Kari.application_support_path, 'SKIndex'))
      @filenames = Dir[file_fixture('normal/ri/**/*.*')]
    else
      raise "Stoopid SearchKit couldn't create a new index when we wanted it too"
    end
  end
  
  after do
    @index.close if @index
  end
  
  it "loads from path" do
    @index.should.be.kind_of?(Index)
    @index.index.should.not.be.nil
  end
  
  it "returns its count" do
    @index.lopsidedCount.should == 0;
    @index.count.should == 0
  end
  
  it "increases the count when a document is added" do
    @index.count.should == 0
    @index.addDocument(@filenames.first)
    @index.flush
    @index.count.should == 1
  end
  
  it "increases the count when a number of documents are added" do
    @index.count.should == 0
    @filenames[0..3].each do |filename|
      @index.addDocument(filename)
    end
    @index.flush
    @index.count.should == 4
  end
  
  it "adds documents with text" do
    @index.count.should == 0
    @index.addDocument(@filenames.first, withText:"Heya!")
    @index.flush
    @index.count.should == 1
  end
  
  it "removes a document after it was added" do
    @index.addDocument(@filenames.first, withText:"Heya!")
    @index.flush
    @index.count.should == 1
    @index.removeDocument(@filenames.first)
    @index.count.should == 0
  end
  
  it "compacts the index" do
    lambda {
      @index.compact
    }.should.not.raise
  end
end
