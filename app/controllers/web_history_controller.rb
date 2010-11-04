class WebHistoryController
  attr_writer :historyMenu
  attr_writer :webViewController
  
  def init
    if super
      WebHistory.optionalSharedHistory = @history = OrderedWebHistory.alloc.init
      
      # Ensure the application support directory
      application_support_path = Kari.application_support_path
      FileUtils.mkdir_p(application_support_path) unless File.exist?(application_support_path)
      
      @history_file_path = NSURL.fileURLWithPath(File.join(application_support_path, 'BrowseHistory'))
      
      self
    end
  end
  
  def awakeFromNib
    NSDistributedNotificationCenter.defaultCenter.addObserver(self,
      selector: 'webViewAddedItem:',
          name: 'WebHistoryItemsAddedNotification',
        object: nil
    )
    NSDistributedNotificationCenter.defaultCenter.addObserver(self,
      selector: 'webViewDidFinishLoading:',
          name: 'WebViewProgressFinishedNotification',
        object: nil
    )
    NSDistributedNotificationCenter.defaultCenter.addObserver(self,
      selector: 'historyDidFinishLoading:',
          name: 'WebHistoryLoadedNotification',
        object: nil
    )
    
    @history.loadFromURL(@history_file_path, error: nil)
  end
  
  def goToHistoryItem(sender)
    @webViewController.load_url sender.representedObject.URLString
  end
  
  def clearHistory(sender)
    @history.removeAllItems
    lastHistoryItem.downto(3) { |idx| @historyMenu.removeItemAtIndex(idx) }
    File.delete(@history_file_path.relativePath)
  end
  
  def validateMenuItem(item)
    case item.action
    when 'clearHistory:' then File.exist? @history_file_path.relativePath
    else
      true
    end
  end
  
  def webViewAddedItem(notification)
    notification.userInfo[WebHistoryItemsKey].each do |history_item|
      @history.removeItems([history_item]) unless @webViewController.bookmarkable?
    end
  end
  
  def webViewDidFinishLoading(notification)
    if history_item = @history.last
      if @historyMenu.itemWithTitle(history_item.title).nil? and @webViewController.bookmarkable?
        saveHistory
        addMenuItemForHistoryItem(history_item)
      end
    end
  end
  
  def historyDidFinishLoading(notification)
    @history.allItems.each { |history_item| addMenuItemForHistoryItem history_item }
  end
  
  private
  
  def saveHistory
    @history.saveToURL_error(@history_file_path)
  end
  
  def lastHistoryItem
    @historyMenu.numberOfItems.to_i - 3
  end
  
  def addMenuItemForHistoryItem(history_item)
    menu_item = NSMenuItem.alloc.initWithTitle_action_keyEquivalent(history_item.title, "goToHistoryItem:", '')
    menu_item.target = self
    menu_item.representedObject = history_item
    @historyMenu.insertItem_atIndex(menu_item, lastHistoryItem + 1)
  end
end