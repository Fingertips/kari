class ApplicationController < Rucola::RCController
  def self.concerned_with(name)
    require File.expand_path("../application_controller/#{name}", __FILE__)
  end
  
  concerned_with 'split_view'
  concerned_with 'web_view'
  concerned_with 'search'
  
  ib_outlet :classBrowser
  ib_outlet :classTreeController
  ib_outlet :webView
  ib_outlet :webViewController
  ib_outlet :window
  ib_outlet :resultsScrollView
  ib_outlet :searchController
  ib_outlet :searchTextField
  ib_outlet :searchProgressIndicator
  ib_outlet :splitView
  ib_outlet :tabView
  ib_outlet :toggleClassBrowserVisbilityButton
  
  kvc_accessor :class_tree
  kvc_accessor :processing
  kvc_accessor :search_mode
  
  def after_init
    self.search_mode = false
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
    
    Manager.bootstrap if Manager.first_run?
    
    @processing = 0
    self.class_tree = ClassTreeNode.classTreeNodesWithHashTree(Manager.instance.namespace)
    @watcher = Watcher.alloc.init
    @watcher.start
    
    @searchController.results = Manager.instance.descriptions.map do |name, definitions|
      OSX::ScoredRubyName.alloc.initWithName_karidocFilename_query(
        name,
        RubyName.karidoc_filename(Manager.current_filepath, name),
        nil
      )
    end
    
    OSX::NSTimer.scheduledTimerWithTimeInterval_target_selector_userInfo_repeats(5, @watcher, 'signal:', nil, true)
    
    @classTreeController.objc_send(
      :addObserver, self,
       :forKeyPath, 'selectionIndexPaths',
          :options, OSX::NSKeyValueObservingOptionNew,
          :context, nil
    )
    
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
  
  def rebuildIndex
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
    preferences.save
    @watcher.stop
    Manager.instance.close
  end
  
  def windowWillClose(notification)
    OSX::NSApplication.sharedApplication.terminate(self)
  end
  
  def changedSearchFilter(sender)
    puts sender.selectedTag
  end
end