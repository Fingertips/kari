class ApplicationController < Rucola::RCController
  def self.concerned_with(name)
    require File.expand_path("../application_controller/#{name}", __FILE__)
  end
  
  concerned_with 'split_view'
  concerned_with 'web_view'
  concerned_with 'search'
  
  attr_writer :window
  attr_writer :webView
  attr_writer :webViewController
  attr_writer :searchController
  attr_writer :searchProgressIndicator
  attr_writer :searchTextField
  attr_writer :bookmarkController
  attr_writer :resultsScrollView
  attr_writer :addBookmarkToolbarButton
  attr_writer :classBrowser
  attr_writer :classTreeController
  attr_writer :splitView
  attr_writer :toggleClassBrowserVisbilityButton
  
  attr_accessor :class_tree
  attr_accessor :processing
  attr_accessor :search_mode
  
  def after_init
    self.search_mode = false
    PreferencesController.registerDefaults
    OSX::NSApplication.sharedApplication.setDelegate(self)
  end
  
  def awakeFromNib
    # First things first, make it look as it should!
    setup_splitView!
    
    # Register notifications
    OSX::NSDistributedNotificationCenter.defaultCenter.objc_send(
      :addObserver, self,
         :selector, 'externalRequestForDocumentation:',
             :name, 'KariOpenDocumentation',
           :object, nil
    )
    OSX::NSDistributedNotificationCenter.defaultCenter.objc_send(
      :addObserver, self,
         :selector, 'finishedIndexing:',
             :name, 'KariDidFinishIndexing',
           :object, nil
    )
    
    @processing = 0
    self.class_tree = ClassTreeNode.classTreeNodesWithHashTree(Manager.instance.namespace)
    @watcher = Watcher.new
    
    @classTreeController.objc_send(
      :addObserver, self,
       :forKeyPath, 'selectionIndexPaths',
          :options, OSX::NSKeyValueObservingOptionNew,
          :context, nil
    )
    
    # Lets wrap it up!
    @splitView.delegate = self
    
    @window.delegate = self
    @bookmarkController.delegate = self
    @searchController.delegate = self
    @webViewController.delegate = self
    @watcher.delegate = self
    @webViewController.home!
  end
  
  def observeValueForKeyPath_ofObject_change_context(key_path, object, change, context)
    # `node' is nil when the selection changes when we load a new tree.
    # We probably want to store the current selectionIndexPath as well before loading the new tree.
    if node = @classTreeController.selectedObjects.first
      unless !node.path or node.path.empty?
        @webViewController.load_file node.path
      else
        log.debug("Can't open class browser at: `#{node.path}'")
      end
    end
  end
  
  def externalRequestForDocumentation(notification)
    query = notification.userInfo['query']
    @searchController.search(query) unless query.nil? || query.empty?
  end
  
  def openPreferencesWindow(sender)
    PreferencesController.alloc.init.showWindow(self)
  end
  
  def rebuildIndex
    @watcher.forceRebuild
  end
  
  def startedIndexing(notification)
    self.processing += 1
  end
  
  def finishedIndexing(notification)
    self.class_tree = ClassTreeNode.classTreeNodesWithHashTree(Manager.instance.namespace)
    if self.processing > 0
      self.processing -= 1
    end
  end
  
  def activateSearchField(sender = nil)
    @window.makeFirstResponder(@searchTextField)
  end
  
  def applicationDidFinishLaunching(aNotification)
    activateSearchField
  end
  
  def applicationWillTerminate(aNotification)
    PreferencesController.synchronize
    @watcher.stop
    Manager.instance.close
  end
  
  def windowWillClose(notification)
    OSX::NSApplication.sharedApplication.terminate(self)
  end
  
  def bookmarkClicked(bookmark)
    @webViewController.load_url bookmark.url
  end
  
  def changedSearchFilter(sender)
    puts sender.selectedTag
  end
end