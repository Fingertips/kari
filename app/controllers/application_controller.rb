class ApplicationController
  def self.concerned_with(name)
    require File.expand_path("../application_controller/#{name}", __FILE__)
  end
  
  concerned_with 'class_tree'
  concerned_with 'search'
  concerned_with 'split_view'
  concerned_with 'web_view'
  
  attr_writer :classBrowser
  attr_writer :classTreeController
  attr_writer :webView
  attr_writer :webViewController
  attr_writer :window
  attr_writer :resultsScrollView
  attr_writer :searchController
  attr_writer :searchTextField
  attr_writer :searchProgressIndicator
  attr_writer :splitView
  attr_writer :tabView
  attr_writer :toggleClassBrowserVisbilityButton
  
  attr_accessor :class_tree
  attr_accessor :processing
  attr_accessor :search_mode
  
  def init
    if super
      self.search_mode = false
      NSApplication.sharedApplication.setDelegate(self)
      self
    end
  end
  
  def awakeFromNib
    # Initialize the UI
    setup_splitView!
    setup_classTree!
    setup_search!
    
    # Register notifications
    NSDistributedNotificationCenter.defaultCenter.addObserver(self,
      selector: 'externalRequestForDocumentation:',
          name: 'KariOpenDocumentation',
        object: nil
    )
    
    Manager.bootstrap if Manager.first_run?
    
    @processing = 0
    
    @watcher = Watcher.alloc.init
    @watcher.start
    
    NSTimer.scheduledTimerWithTimeInterval(5, target: @watcher, selector: 'signal:', userInfo: nil, repeats: true)
    
    # Lets wrap it up!
    @splitView.delegate = self
    
    @window.delegate = self
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
        karidoc_filename = File.join(Manager.instance.filepath, node.path)
        @webViewController.load_file(karidoc_filename)
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
  
  def rebuildIndex(sender)
    @watcher.forceRebuild
  end
  
  def startedIndexing(sender)
    self.processing += 1
  end
  
  def finishedIndexing(sender)
    if self.processing > 0
      self.processing -= 1
      
      Manager.reset!
      
      currentPath = @classTreeController.selectionIndexPath
      self.class_tree = ClassTreeNode.classTreeNodesWithHashTree(Manager.instance.namespace)
      @classTreeController.setSelectionIndexPath(currentPath)
      
      @searchController.setResultsForDescriptions(Manager.instance.descriptions)
      
      Thread.start { Manager.cleanup }
    end
  end
  
  def activateSearchField(sender = nil)
    @window.makeFirstResponder(@searchTextField)
  end
  
  def applicationDidFinishLaunching(aNotification)
    activateSearchField
  end
  
  def applicationWillTerminate(aNotification)
    preferences.synchronize
    @watcher.stop
    Manager.instance.close
  end
  
  def windowWillClose(notification)
    NSApplication.sharedApplication.terminate(self)
  end
  
  def changedSearchFilter(sender)
    puts sender.selectedTag
  end
end