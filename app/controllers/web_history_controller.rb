class WebHistory
  def last
    if last_day = orderedLastVisitedDays.first
      orderedItemsLastVisitedOnDay(last_day).first
    end
  end
  
  def allItems
    orderedLastVisitedDays.collect{ |day| orderedItemsLastVisitedOnDay(day).to_a }.flatten.reverse
  end
end

class WebHistoryController < Rucola::RCController
  attr_writer :historyMenu
  attr_writer :webViewController
  
  # # Only allow bookmarkable urls in the history
  # notify_on WebHistoryItemsAddedNotification do |notification|
  #   notification.userInfo[WebHistoryItemsKey].each do |history_item|
  #     @history.removeItems([history_item]) unless @webViewController.bookmarkable?
  #   end
  # end
  # 
  # # Add the history item to the history menu if it doesn't exist yet
  # notify_on WebViewProgressFinishedNotification do |notification|
  #   if history_item = @history.last
  #     if @historyMenu.itemWithTitle(history_item.title).nil? and @webViewController.bookmarkable?
  #       saveHistory
  #       addMenuItemForHistoryItem(history_item)
  #     end
  #   end
  # end
  # 
  # # When done loading the history create the menu
  # notify_on WebHistoryLoadedNotification do |notification|
  #   @history.allItems.each { |history_item| addMenuItemForHistoryItem history_item }
  # end
  
  def after_init
    WebHistory.optionalSharedHistory = @history = WebHistory.alloc.init
    
    # Ensure the application support directory
    application_support_path = Rucola::RCApp.application_support_path
    FileUtils.mkdir_p(application_support_path) unless File.exist?(application_support_path)
    
    @history_file_path = NSURL.fileURLWithPath(File.join(application_support_path, 'BrowseHistory'))
  end
  
  def awakeFromNib
    @history.loadFromURL_error(@history_file_path)
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