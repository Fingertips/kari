require File.expand_path('../../test_helper', __FILE__)

describe 'SABookmarkBar' do
  before do
    bookmark1 = { :id => 0, :title => 'bookmark1', :url => 'http://127.0.0.1/item1', :order_index => 3 }
    bookmark2 = { :id => 1, :title => 'bookmark2', :url => 'http://127.0.0.1/item2', :order_index => 1 }
    bookmark3 = { :id => 3, :title => 'bookmark3', :url => 'http://127.0.0.1/item3', :order_index => 2 }
    @bookmarks = [bookmark1, bookmark2, bookmark3].map { |hash| OSX::SABookmark.alloc.initWithHash(hash) }
    @bookmarks.each {|b| b.stubs(:frame).returns(OSX::NSRect.new(0, 0, 20, 20)) }
    
    @bookmarkBar = OSX::SABookmarkBar.alloc.init
    @bookmarkBar.stubs(:frame).returns(OSX::NSRect.new(0, 0, 300, 20))
    
    overflowButton = mock('Overflow Button')
    overflowButton.stubs(:frame).returns(OSX::NSRect.new(0, 0, 20, 20))
    @bookmarkBar.instance_variable_set(:@overflowButton, overflowButton)
    
    @bookmarkBar.bookmarks = @bookmarks
  end
  
  # FIX SEGFAULT!
  # after do
  #   @bookmarkBar = nil
  #   @bookmarks = nil
  # end
  
  # def selectedBookmark; end
  
  # it "should take an array of bookmarks" do
  #   bookmarkBar = OSX::SABookmarkBar.alloc.init
  #   bookmarkBar.bookmarks = @bookmarks
  #   bookmarkBar.bookmarks.should_not be_empty
  # end
  
  # it "should return the order_index for a given bookmark" do
  #   @bookmarkBar.orderIndexForBookmark(@bookmarks.first).should eql(3)
  # end
  
  it "should send clicked events to it's delegate" do
    the_delegate = mock("TheDelegate")
    the_delegate.expects(:bookmarkClicked).with(@bookmarks.first)
    @bookmarkBar.delegate = the_delegate
    @bookmarkBar.ivar(:buttons).last.mouseUp(nil)
  end
  
  it "should set the titles for the buttons to the titles in the bookmarks in the order as specified in order_index" do
    bookmark_buttons = @bookmarkBar.ivar(:buttons)
    bookmark_buttons.map{|b| b.title.to_s }.should == ['bookmark2', 'bookmark3', 'bookmark1']
  end
end