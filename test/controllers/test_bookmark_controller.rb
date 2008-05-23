require File.expand_path('../../test_helper', __FILE__)

# describe 'BookmarkController' do
#   include GlobalSpecHelper
#   
#   before do
#     @bookmark_controller = BookmarkController.alloc.init
#     @bookmark_controller.bookmarkBar = OSX::SABookmarkBar.alloc.init
#   end
#   
#   # it "should have a reference to a SABookmarkBar instance, assign the bookmarks and set itself as it's delegate on awakeFromNib" do
#   #   @bookmark_controller.instance_variable_set :@bookmarks, make_bookmarks(PreferencesController::DEFAULT_BOOKMARKS)
#   #   
#   #   # bookmark_menu_mock = mock('BookmarkMenu')
#   #   # bookmark_menu_mock.expects(:numberOfItems).returns(4)
#   #   # bookmark_menu_mock.expects(:addItem).exactly(PreferencesController::DEFAULT_BOOKMARKS.length).times
#   #   # @bookmark_controller.instance_variable_set :@bookmarkMenu, bookmark_menu_mock
#   #   
#   #   #@bookmark_controller.expects(:createMenuItemForBookmark).exactly(PreferencesController::DEFAULT_BOOKMARKS.length).times
#   #   
#   #   @bookmark_controller.expects(:populateBookmarkMenu)
#   #   
#   #   @bookmark_controller.awakeFromNib
#   #   @bookmark_controller.bookmarkBar.should be_kind_of(OSX::SABookmarkBar)
#   #   @bookmark_controller.bookmarkBar.delegate.should eql(@bookmark_controller)
#   #   @bookmark_controller.bookmarkBar.instance_variable_get(:@buttons).should_not be_empty
#   # end
#   
#   it "should send clicked events to the delegate" do
#     the_bookmark = mock("TheBookmark")
#     the_delegate = mock("TheDelegate")
#     the_delegate.expects(:bookmarkClicked).once.with(the_bookmark)
#     @bookmark_controller.delegate = the_delegate
#     @bookmark_controller.bookmarkClicked(the_bookmark)
#   end
# end

describe "BookmarkController" do
  tests BookmarkController
  
  def after_setup
    ib_outlets :bookmarkBar => OSX::NSView.alloc.init
    
    @delegate = stub_everything("Delegate")
    controller.delegate = @delegate
  end
  
  it "should send clicked events to the delegate" do
    the_bookmark = mock("TheBookmark")
    @delegate.expects(:bookmarkClicked).once.with(the_bookmark)
    controller.bookmarkClicked(the_bookmark)
  end
  
  it "should be able to toggle the visibility of the bookmarks bar" do
    bookmarkBar.hidden = false
    
    controller.toggleVisibilityBookmarksBar(nil)
    bookmarkBar.hidden?.should.be true
    
    controller.toggleVisibilityBookmarksBar(nil)
    bookmarkBar.hidden?.should.be false
  end
  
  it "should let the delegate know that the visibility of the bookmarks bar has been changed" do
    @delegate.expects(:bookmarkBarToggledVisibility).with(bookmarkBar)
    controller.toggleVisibilityBookmarksBar(nil)
  end
end