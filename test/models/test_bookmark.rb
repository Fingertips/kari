require File.expand_path('../../test_helper', __FILE__)

module BookmarkSpecHelpers
  def attributes
    { 'title' => 'String', 'url' => 'file:///Karidoc/String.karidoc' }
  end
  
  def create_bookmark
    Bookmark.createWithHash(attributes.dup)
  end
end

describe "Bookmark" do
  before do
    Bookmark.reset!
  end
  
  it "should create from a hash" do
    bookmark = create_bookmark
    bookmark.title.should == attributes['title']
    bookmark.url.should == attributes['url']
  end
  
  it "should automatically set the order_index when creating from hash" do
    create_bookmark.order_index.should == 0
    create_bookmark.order_index.should == 1
    create_bookmark.order_index.should == 2
  end
  
  it "should automatically add an id and order index when not specified during creation" do
    bookmark = create_bookmark
    bookmark.id.should.not.be.nil
    bookmark.order_index.should.not.be.nil
  end
  
  it "should find bookmarks by its ID" do
    bookmark1 = create_bookmark
    bookmark2 = create_bookmark
    
    Bookmark[bookmark1.id].should == bookmark1
    Bookmark[bookmark2.id].should == bookmark2
    
    Bookmark['unknown'].should.be.nil
  end
  
  it "should reset its class data" do
    bookmark = create_bookmark
    Bookmark[bookmark.id].should == bookmark
    Bookmark.reset!
    Bookmark[bookmark.id].should.be.nil
  end
  
  private
  include BookmarkSpecHelpers
end

describe "A Bookmark" do
  before do
    Bookmark.reset!
  end
  
  it "should init with a data hash" do
    bookmark = Bookmark.alloc.initWithHash(attributes.merge('id' => 12, 'order_index' => 14))
    bookmark.title.should == attributes['title']
    bookmark.url.should == attributes['url']
    bookmark.id.should == 12
    bookmark.order_index.should == 14
    
    Bookmark[bookmark.id].should == bookmark
  end
  
  it "should sort on creation sequence" do
    first = create_bookmark
    second = create_bookmark
    third = create_bookmark
    
    [second, third, first].sort.should == [first, second, third]
  end
  
  it "should coerce to hash" do
    bookmark = create_bookmark
    hash     = bookmark.to_hash
    
    hash['order_index'].should == 0
    hash['id'].should == 0
    hash['title'].should == attributes['title']
    hash['url'].should == attributes['url']
  end
  
  private
  include BookmarkSpecHelpers
end