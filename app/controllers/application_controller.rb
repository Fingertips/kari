class ApplicationController < Rucola::RCController
  def self.concerned_with(name)
    require File.expand_path("../application_controller/#{name}", __FILE__)
  end
  
  concerned_with 'split_view'
  concerned_with 'web_view'
  concerned_with 'search'
  
  ib_outlet :window
  ib_outlet :webView
  ib_outlet :webViewController
  ib_outlet :searchController
  ib_outlet :searchProgressIndicator
  ib_outlet :searchTextField
  ib_outlet :bookmarkController
  ib_outlet :resultsScrollView
  ib_outlet :addBookmarkToolbarButton
  ib_outlet :classBrowser
  ib_outlet :classTreeController
  ib_outlet :splitView
  
  kvc_accessor :processing, :class_tree
  
  def after_init
    PreferencesController.registerDefaults
    OSX::NSApplication.sharedApplication.setDelegate(self)
  end
  
  def awakeFromNib
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
  
  def printWebViewContents(sender)
    print_info = OSX::NSPrintInfo.sharedPrintInfo
    print_info.topMargin = 30
    print_info.leftMargin = 35
    print_info.horizontallyCentered = false
    print_info.verticallyCentered = false
    
    OSX::NSPrintOperation.objc_send(
      :printOperationWithView, @webView.mainFrame.frameView.documentView,
                   :printInfo, print_info
    ).runOperation
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
  
  private
  
  def bring_webView_to_front!
    @webView.hidden = false
    @resultsScrollView.hidden = true
  end
end