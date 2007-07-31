require File.dirname(File.expand_path(__FILE__)) + "/../SABookmarkBar/SABookmarkBar"

describe OSX::SABookmarkBar do
  before do
    bookmark1 = { :id => 0, :title => 'bookmark1', :url => 'http://127.0.0.1/item1', :order_index => 3 }
    bookmark2 = { :id => 1, :title => 'bookmark2', :url => 'http://127.0.0.1/item2', :order_index => 1 }
    bookmark3 = { :id => 3, :title => 'bookmark3', :url => 'http://127.0.0.1/item3', :order_index => 2 }
    @bookmarks = [bookmark1, bookmark2, bookmark3].map { |hash| OSX::SABookmark.alloc.initWithHash(hash) }
    #p @bookmarks
  end
  
  def selectedBookmark; end
  
  it "should take an array of bookmarks" do
    bookmarkBar = OSX::SABookmarkBar.alloc.init
    bookmarkBar.addBookmarks_withSelector_withSender(@bookmarks, 'selectedBookmark', self)
    
    #bookmarkBar.setReorderedItemsDelegate_withSelector(self, 'reorderedBookmark')
  end
  
  it "should set the titles for the buttons to the titles in the bookmarks in the order as specified in order_index" do
    bookmarkBar = OSX::SABookmarkBar.alloc.init
    bookmarkBar.addBookmarks_withSelector_withSender(@bookmarks, 'selectedBookmark', self)
    bookmark_buttons = bookmarkBar.instance_variable_get(:@buttons)
    bookmark_buttons.map{|b| b.title.to_s }.should eql(['bookmark2', 'bookmark3', 'bookmark1'])
  end
end