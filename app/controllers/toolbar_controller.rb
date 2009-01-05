class ToolbarController < Rucola::RCController
  attr_writer :window, :historyBackAndForwardView, :searchView, :addBookmarkView, :toggleClassBrowserView
  
  def after_init
    @toolbar = NSToolbar.alloc.initWithIdentifier('MainWindowToolbar')
    @toolbar.delegate = self
    @toolbar.displayMode = NSToolbarDisplayModeIconOnly
  end
  
  def awakeFromNib
    @window.showsToolbarButton = false
    @window.toolbar = @toolbar
  end
  
  TOOLBAR_ITEMS = ['HistoryBackAndForwardItem', 'AddBookmarkItem', 'ToggleClassBrowserItem', NSToolbarFlexibleSpaceItemIdentifier, 'SearchItem']
  def toolbarAllowedItemIdentifiers(toolbar)
    TOOLBAR_ITEMS
  end
  def toolbarDefaultItemIdentifiers(toolbar)
    TOOLBAR_ITEMS
  end
  
  def toolbar_itemForItemIdentifier_willBeInsertedIntoToolbar(toolbar, identifier, flag)
    item = NSToolbarItem.alloc.initWithItemIdentifier(identifier)
    return item if identifier == NSToolbarFlexibleSpaceItemIdentifier
    custom_view = self.instance_variable_get("@#{identifier[0...1].downcase + identifier[1..-1].gsub(/Item$/, 'View')}".to_sym)
    item.view = custom_view
    item.minSize = item.maxSize = NSMakeSize(NSWidth(custom_view.frame), NSHeight(custom_view.frame))
    return item
  end
end