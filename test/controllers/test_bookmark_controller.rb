require File.expand_path('../../test_helper', __FILE__)

describe "BookmarkController" do
  tests BookmarkController
  
  def after_setup
    Bookmark.reset!
    
    ib_outlets :bookmarkMenu => OSX::NSMenu.alloc.init,
               :addBookmarkTitleTextField => OSX::NSTextField.alloc.init,
               :removeBookmarkPopup => OSX::NSPopUpButton.alloc.init
    
    @bookmarks = [
      { 'id' => 0, 'order_index' => 0, 'title' => 'String', 'url' => 'file:///Karidoc/String.karidoc' },
      { 'id' => 1, 'order_index' => 1, 'title' => 'Array',  'url' => 'file:///Karidoc/Array.karidoc' }
    ]
    preferences.general.bookmarks = @bookmarks.to_ns
    
    @hash = { 'id' => 2, 'order_index' => 2, 'title' => 'Hash',  'url' => 'file:///Karidoc/Hash.karidoc' }
  end
  
  it "should return a list of current bookmarks" do
    controller.bookmarks.each_with_index do |bookmark, index|
      bookmark.should.be.instance_of Bookmark
      bookmark.to_hash.should == @bookmarks[index]
    end
  end
  
  it "should populate the bookmark menu with items for each bookmark" do
    controller.populateBookmarkMenu
    
    bookmarkMenu.itemArray.last(2).each_with_index do |item, index|
      item.tag.should == @bookmarks[index]['id']
      item.title.should == @bookmarks[index]['title']
    end
  end
  
  it "should populate the bookmark menu when awoken from nib" do
    controller.expects(:populateBookmarkMenu)
    controller.awakeFromNib
  end
  
  it "should add a bookmark with data from the addBookmarkSheet, save the changes, and close the addBookmarkSheet" do
    addBookmarkTitleTextField.stringValue = 'Hash'
    webViewController.stubs(:url).returns('file:///Karidoc/Hash.karidoc')
    
    controller.expects(:bookmarksChanged)
    controller.expects(:closeAddBookmarkSheet)
    controller.addBookmark
    
    controller.bookmarks.map { |b| b.to_hash }.should == (@bookmarks << @hash)
  end
  
  it "should save the bookmarks to the user defaults and reset the bookmark menu after a change to the bookmarks" do
    controller.bookmarks << @hash
    
    preferences.expects(:save)
    controller.expects(:resetBookmarkMenu)
    controller.send(:bookmarksChanged)
    
    preferences.general.bookmarks.should == (@bookmarks << @hash)
  end
  
  it "should remove the bookmark selected in the removeBookmarkSheet, remove it from the bookmarks and menu, and close the removeBookmarkSheet" do
    removeBookmarkPopup.addItemWithTitle('String')
    
    controller.expects(:bookmarksChanged)
    controller.expects(:closeRemoveBookmarkSheet)
    controller.removeBookmark(nil)
    
    controller.bookmarks.map { |b| b.to_hash }.should == [@bookmarks.last]
  end
  
  it "should forward the bookmark that was selected to the delegate" do
    bookmark = controller.bookmarks.first
    item = OSX::NSMenuItem.alloc.init
    item.tag = bookmark.id
    
    delegate = mock('Delegate')
    delegate.expects(:bookmarkSelected).with(bookmark)
    controller.delegate = delegate
    
    controller.bookmarkSelected(item)
  end
end
