require File.dirname(File.expand_path(__FILE__)) + "/../SABookmarkBar/SABookmarkBar"

describe OSX::SABookmarkBar do
  before do
    bookmark1 = { :id => 0, :title => 'bookmark1', :url => 'http://127.0.0.1/item1', :order_index => 3 }
    bookmark2 = { :id => 1, :title => 'bookmark2', :url => 'http://127.0.0.1/item2', :order_index => 1 }
    bookmark3 = { :id => 3, :title => 'bookmark3', :url => 'http://127.0.0.1/item3', :order_index => 2 }
    @bookmarks = [bookmark1, bookmark2, bookmark3].map { |hash| OSX::SABookmark.alloc.initWithHash(hash) }
    
    @bookmarkBar = OSX::SABookmarkBar.alloc.init
    @bookmarkBar.stub!(:frame).and_return(OSX::NSRect.new(0, 0, 300, 20))
    @bookmarkBar.bookmarks = @bookmarks
  end
  
  def selectedBookmark; end
  
  it "should take an array of bookmarks" do
    bookmarkBar = OSX::SABookmarkBar.alloc.init
    bookmarkBar.bookmarks = @bookmarks
    bookmarkBar.bookmarks.should_not be_empty
  end
  
  # it "should return the order_index for a given bookmark" do
  #   @bookmarkBar.orderIndexForBookmark(@bookmarks.first).should eql(3)
  # end
  
  it "should send clicked events to it's delegate" do
    the_delegate = mock("TheDelegate")
    the_delegate.should_receive(:bookmarkClicked).with(@bookmarks.first)
    @bookmarkBar.delegate = the_delegate
    @bookmarkBar.instance_variable_get(:@buttons).last.mouseUp(nil)
  end
  
  it "should set the titles for the buttons to the titles in the bookmarks in the order as specified in order_index" do
    bookmark_buttons = @bookmarkBar.instance_variable_get(:@buttons)
    bookmark_buttons.map{|b| b.title.to_s }.should eql(['bookmark2', 'bookmark3', 'bookmark1'])
  end
end