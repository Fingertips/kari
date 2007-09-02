require 'osx/cocoa'

class BookmarkController < OSX::NSObject
  ib_outlet :bookmarkBar, :bookmarkMenuItem
  attr_accessor :bookmarkBar, :delegate
  
  def awakeFromNib
    @bookmarkBar.bookmarks = self.bookmarks
    @bookmarkBar.delegate = self
    self.populateBookmarkMenu
  end
  
  def bookmarks
    @bookmarks ||= self.get_bookmarks
  end
  
  DEFAULT_BOOKMARKS = ['Object', 'String', 'Array', 'Hash', 'Numeric']
  def get_bookmarks
    unless hash_bookmarks = OSX::NSUserDefaults.standardUserDefaults.objectForKey('Bookmarks')
      hash_bookmarks = []
      DEFAULT_BOOKMARKS.each_with_index do |title, idx|
        hash_bookmarks.push({:id => idx, :title => title, :url => "http://127.0.0.1:9999/show/#{title}", :order_index => idx})
      end
      # store the standard bookmarks in the preference file
      OSX::NSUserDefaults.standardUserDefaults.setObject_forKey(hash_bookmarks, 'Bookmarks')
    end
    return hash_bookmarks.map {|h| OSX::SABookmark.alloc.initWithHash(h) }
  end
  
  def bookmarkClicked(bookmark)
    @delegate.bookmarkClicked(bookmark)
  end
  
  def bookmarkMenuItemSelected(menuItem)
    self.bookmarkClicked OSX::SABookmark.bookmarkForID(menuItem.tag)
  end
  
  def bookmarksReordered(dragged_bookmark)
    @bookmarks = @bookmarkBar.bookmarks
    self.saveBookmarks
    self.resetBookmarkMenu
  end
  
  def saveBookmarks
    OSX::NSUserDefaults.standardUserDefaults.setObject_forKey(@bookmarks.map { |b| b.to_hash }, 'Bookmarks')
  end
  
  def addBookmark(title, url)
    puts title, url
    bookmark = OSX::SABookmark.createWithHash :title => title, :url => url
    @bookmarks.push bookmark
    self.saveBookmarks
    self.resetBookmarkMenu
    @bookmarkBar.addBookmarkButton(bookmark)
  end
  
  def populateBookmarkMenu
    self.bookmarks.sort_by { |bookmark| bookmark.order_index }.each do |bookmark|
      @bookmarkMenuItem.submenu.addItem createMenuItemForBookmark(bookmark)
    end
  end
  
  def createMenuItemForBookmark(bookmark)
    item = OSX::NSMenuItem.alloc.init
    item.title = bookmark.title
    item.tag = bookmark.id
    item.enabled = true
    item.target = self
    item.action = 'bookmarkMenuItemSelected:'
    key_equivalent = @bookmarkMenuItem.submenu.numberOfItems.to_i - 1
    if key_equivalent < 11
      item.keyEquivalent = key_equivalent == 10 ? '0' : key_equivalent.to_s
      item.keyEquivalentModifierMask = OSX::NSCommandKeyMask
    end
    return item
  end
  
  def resetBookmarkMenu
    (@bookmarkMenuItem.submenu.numberOfItems.to_i - 1).downto(2) { |idx| @bookmarkMenuItem.submenu.removeItemAtIndex(idx) }
    self.populateBookmarkMenu
  end
  
end
