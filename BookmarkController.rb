require 'osx/cocoa'

class BookmarkController < OSX::NSObject
  ib_outlet :window, :bookmarkBar, :bookmarkMenu
  ib_outlet :addBookmarkSheet, :addBookmarkTitleTextField
  ib_outlet :removeBookmarkSheet, :removeBookmarkPopup
  ib_outlet :webViewController
  
  attr_accessor :bookmarkBar, :delegate
  
  def awakeFromNib
    @bookmarkBar.bookmarks = self.bookmarks
    @bookmarkBar.delegate = self
    self.populateBookmarkMenu
  end
  
  # crud
  
  def bookmarks
    @bookmarks ||= OSX::NSUserDefaults.standardUserDefaults.objectForKey('Bookmarks').map {|h| OSX::SABookmark.alloc.initWithHash(h) }
  end
  
  def saveBookmarks
    OSX::NSUserDefaults.standardUserDefaults.setObject_forKey(@bookmarks.map { |b| b.to_hash }, 'Bookmarks')
  end
  
  def addBookmark(title, url)
    @bookmarks.push OSX::SABookmark.createWithHash({ :title => @addBookmarkTitleTextField.stringValue, :url => @webViewController.url })
    self.bookmarksChanged
    self.closeAddBookmarkSheet(self)
  end
  
  def removeBookmark(sender)
    selected_title = @removeBookmarkPopup.titleOfSelectedItem.to_s
    @bookmarks.delete @bookmarks.select{ |bm| bm.title == selected_title }.first
    self.bookmarksChanged
    self.closeRemoveBookmarkSheet(self)
  end
  
  def clearBookmarks(sender)
    @bookmarks = []
    self.bookmarksChanged
  end
  
  # events
  
  def bookmarkClicked(bookmark)
    @delegate.bookmarkClicked(bookmark)
  end
  
  def bookmarkMenuSelected(menuItem)
    self.bookmarkClicked OSX::SABookmark.bookmarkForID(menuItem.tag)
  end
  
  def bookmarksReordered(dragged_bookmark)
    @bookmarks = @bookmarkBar.bookmarks
    self.bookmarksChanged
  end
  
  def bookmarksChanged
    self.saveBookmarks
    self.resetBookmarkMenu
    @bookmarkBar.bookmarks = @bookmarks
  end
  
  # bookmark menu
  
  def populateBookmarkMenu
    self.bookmarks.sort_by { |bookmark| bookmark.order_index }.each do |bookmark|
      @bookmarkMenu.addItem createMenuItemForBookmark(bookmark)
    end
  end
  
  def createMenuItemForBookmark(bookmark)
    item = OSX::NSMenuItem.alloc.init
    item.title = bookmark.title
    item.tag = bookmark.id
    item.enabled = true
    item.target = self
    item.action = 'bookmarkMenuSelected:'
    key_equivalent = @bookmarkMenu.numberOfItems.to_i - 3
    if key_equivalent < 11
      item.keyEquivalent = key_equivalent == 10 ? '0' : key_equivalent.to_s
      item.keyEquivalentModifierMask = OSX::NSCommandKeyMask
    end
    return item
  end
  
  def resetBookmarkMenu
    (@bookmarkMenu.numberOfItems.to_i - 1).downto(4) { |idx| @bookmarkMenu.removeItemAtIndex(idx) }
    self.populateBookmarkMenu
  end
  
  # add bookmark sheet
  
  def openAddBookmarkSheet(sender)
    @addBookmarkTitleTextField.stringValue = @webViewController.doc_title
    #@addBookmarkSheetAddButton.highlight(true)
    OSX::NSApp.beginSheet_modalForWindow_modalDelegate_didEndSelector_contextInfo(@addBookmarkSheet, @window, self, 'addBookmarkSheetDidEnd:', nil)
  end
  def closeAddBookmarkSheet(sender)
    OSX::NSApp.endSheet @addBookmarkSheet
  end
  def addBookmarkSheetDidEnd(sender, return_code, context_info)
    @addBookmarkSheet.orderOut(self)
  end
  
  # remove bookmark sheet

  def openRemoveBookmarkSheet(sender)
    @removeBookmarkPopup.removeAllItems
    @removeBookmarkPopup.addItemsWithTitles @bookmarks.sort_by{ |bm| bm.order_index }.map{ |bm| bm.title }
    
    OSX::NSApp.beginSheet_modalForWindow_modalDelegate_didEndSelector_contextInfo(@removeBookmarkSheet, @window, self, 'removeBookmarkSheetDidEnd:', nil)
  end
  def closeRemoveBookmarkSheet(sender)
    OSX::NSApp.endSheet @removeBookmarkSheet
  end
  def removeBookmarkSheetDidEnd(sender, return_code, context_info)
    @removeBookmarkSheet.orderOut(self)
  end
  
end
