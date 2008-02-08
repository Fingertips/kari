class OSX::SABookmarkMenuItem < OSX::NSMenuItem
  attr_accessor :bookmark
  
  def initWithBookmark_action_keyEquivalent(bookmark, action, key)
    if initWithTitle_action_keyEquivalent(bookmark.title, action, key)
      @bookmark = bookmark
      self
    end
  end
end