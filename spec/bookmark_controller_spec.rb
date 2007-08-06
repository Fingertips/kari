require File.dirname(File.expand_path(__FILE__)) + "/../BookmarkController.rb"
require File.dirname(File.expand_path(__FILE__)) + "/../SABookmarkBar/SABookmarkBar.rb"

# class SABookmarkBar
# end

describe BookmarkController do
  before do
    @bookmark_controller = BookmarkController.alloc.init
    @bookmark_controller.bookmarkBar = OSX::SABookmarkBar.alloc.init
  end
  
  it "should have a reference to a SABookmarkBar instance, assign the bookmarks and set itself as it's delegate on awakeFromNib" do
    @bookmark_controller.awakeFromNib
    @bookmark_controller.bookmarkBar.should be_kind_of(OSX::SABookmarkBar)
    @bookmark_controller.bookmarkBar.delegate.should eql(@bookmark_controller)
    @bookmark_controller.bookmarkBar.instance_variable_get(:@buttons).should_not be_empty
  end
  
  it "should send clicked events to the delegate" do
    the_bookmark = mock("TheBookmark")
    the_delegate = mock("TheDelegate")
    the_delegate.should_receive(:bookmarkClicked).once.with(the_bookmark)
    @bookmark_controller.delegate = the_delegate
    @bookmark_controller.bookmarkClicked(the_bookmark)
  end
end