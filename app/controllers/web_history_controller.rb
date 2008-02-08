require "uri"

class OSX::WebHistory
  def allItems
    self.orderedLastVisitedDays.collect{ |day| self.orderedItemsLastVisitedOnDay(day).to_a }.flatten.reverse
  end
end

class WebHistoryController < Rucola::RCController
  ib_outlet :historyMenu
  ib_outlet :webViewController
  
  def after_init
    @history = OSX::WebHistory.alloc.init
    OSX::WebHistory.setOptionalSharedHistory(@history)
    
    @history_file_path = File.expand_path('~/Library/Application Support/Kari/BrowseHistory')

    nc = OSX::NSNotificationCenter.defaultCenter
    
    nc.objc_send :addObserver, self, 
                 :selector,    'historyDidAddItems:',
                 :name,        OSX::WebHistoryItemsAddedNotification,
                 :object,      @history
  end
  
  def awakeFromNib
    self.loadHistory
  end
  
  def loadHistory
    OSX::NSNotificationCenter.defaultCenter.objc_send :addObserver, self, 
                                                      :selector,    'doneLoadingHistory:',
                                                      :name,        OSX::WebHistoryLoadedNotification,
                                                      :object,      nil
    
    @history.loadFromURL_error(OSX::NSURL.fileURLWithPath(@history_file_path)) unless `sw_vers -productVersion`.strip == '10.5' # tmp fix, so we can at least boot on 10.5
  end
  
  def doneLoadingHistory(aNotification)
    @history.allItems.each { |history_item| self.addMenuItemForHistoryItem history_item }
  end
  
  def saveHistory
    @history.saveToURL_error(OSX::NSURL.fileURLWithPath(@history_file_path))
  end
  
  def historyDidAddItems(aNotification)
    aNotification.userInfo.objectForKey(OSX::WebHistoryItemsKey).each do |history_item|
      if history_item.URLString.to_s =~ /^http:\/\/127.0.0.1:\d+\/show\/(.+)$/
        history_item.alternateTitle = $1.gsub(/%3A/, ':').gsub(/%23/, '#').gsub(/%3F/, '?').gsub(/%21/, '!').gsub(/%3D/, '=')
        self.saveHistory
        self.addMenuItemForHistoryItem(history_item)
      else
        # we don't want to store any history item which is not a url like: http://127.0.0.1:9999/show/...
        @history.removeItems [history_item]
      end
    end
  end
  
  def lastHistoryItem
    @historyMenu.numberOfItems.to_i - 3
  end
  
  def addMenuItemForHistoryItem(history_item)
    menu_item = OSX::NSMenuItem.alloc.objc_send :initWithTitle, history_item.alternateTitle,
                                                :action, "goToHistoryItem:",
                                                :keyEquivalent, ""

    menu_item.target = self
    menu_item.representedObject = history_item
    @historyMenu.insertItem_atIndex(menu_item, lastHistoryItem + 1)
  end
  
  def goToHistoryItem(sender)
    @webViewController.load_url sender.representedObject.URLString
  end
  
  def clearHistory(sender)
    @history.removeAllItems
    lastHistoryItem.downto(4) { |idx| @historyMenu.removeItemAtIndex(idx) }
    File.delete(@history_file_path)
  end
end