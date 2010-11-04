class ToolbarController
  attr_writer :window
  attr_writer :historyBackAndForwardView
  attr_writer :searchView
  attr_writer :toggleClassBrowserView
  
  def init
    if super
      @toolbar = NSToolbar.alloc.initWithIdentifier('MainWindowToolbar')
      @toolbar.delegate = self
      @toolbar.displayMode = NSToolbarDisplayModeIconOnly
      self
    end
  end
  
  def awakeFromNib
    @window.showsToolbarButton = false
    @window.toolbar = @toolbar
  end
  
  def toolbar(toolbar, itemForItemIdentifier:identifier, willBeInsertedIntoToolbar:flag)
    item = NSToolbarItem.alloc.initWithItemIdentifier(identifier)
    return item if identifier == NSToolbarFlexibleSpaceItemIdentifier
    custom_view = self.instance_variable_get("@#{identifier[0...1].downcase + identifier[1..-1].gsub(/Item$/, 'View')}".to_sym)
    item.view = custom_view
    item.minSize = item.maxSize = NSMakeSize(NSWidth(custom_view.frame), NSHeight(custom_view.frame))
    return item
  end
  
  TOOLBAR_ITEMS = ['HistoryBackAndForwardItem', 'ToggleClassBrowserItem', NSToolbarFlexibleSpaceItemIdentifier, 'SearchItem']
  def _items(toolbar); TOOLBAR_ITEMS; end
  alias_method :toolbarAllowedItemIdentifiers,    :_items
  alias_method :toolbarDefaultItemIdentifiers,    :_items
  alias_method :toolbarSelectableItemIdentifiers, :_items
end