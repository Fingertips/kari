require 'osx/cocoa'

class ToolbarController < OSX::NSObject
  ib_outlet :window, :historyBackAndForwardView, :fontSmallerAndBiggerView, :searchView, :homeView, :addBookmarkView
  
  def init
    if super_init
      @toolbar = OSX::NSToolbar.alloc.initWithIdentifier('MainWindowToolbar')
      @toolbar.delegate = self
      @toolbar.displayMode = OSX::NSToolbarDisplayModeIconOnly
      return self
    end
  end
  
  def awakeFromNib
    @window.showsToolbarButton = false
    @window.toolbar = @toolbar
  end
  
  TOOLBAR_ITEMS = ['HistoryBackAndForwardItem', 'FontSmallerAndBiggerItem', 'HomeItem', 'AddBookmarkItem', OSX::NSToolbarFlexibleSpaceItemIdentifier, 'SearchItem']
  def toolbarAllowedItemIdentifiers(toolbar)
    TOOLBAR_ITEMS
  end
  def toolbarDefaultItemIdentifiers(toolbar)
    TOOLBAR_ITEMS
  end
  
  def toolbar_itemForItemIdentifier_willBeInsertedIntoToolbar(toolbar, identifier, flag)
    item = OSX::NSToolbarItem.alloc.initWithItemIdentifier(identifier)
    return item if identifier == OSX::NSToolbarFlexibleSpaceItemIdentifier
    custom_view = self.instance_variable_get("@#{identifier[0...1].downcase + identifier[1..-1].gsub(/Item$/, 'View')}".to_sym)
    item.view = custom_view
    item.minSize = item.maxSize = OSX::NSMakeSize(OSX::NSWidth(custom_view.frame), OSX::NSHeight(custom_view.frame))
    return item
  end

end
