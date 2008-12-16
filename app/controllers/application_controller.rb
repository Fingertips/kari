class ApplicationController < Rucola::RCController
  ib_outlet :window
  ib_outlet :webView
  ib_outlet :webViewController
  ib_outlet :searchController
  ib_outlet :searchProgressIndicator
  ib_outlet :searchTextField
  ib_outlet :bookmarkController
  ib_outlet :resultsScrollView
  ib_outlet :addBookmarkToolbarButton
  ib_outlet :classTreeController
  
  kvc_accessor :processing, :class_tree
  
  def after_init
    PreferencesController.registerDefaults
    OSX::NSApplication.sharedApplication.setDelegate(self)
  end
  
  def awakeFromNib
    # Register notifications
    OSX::NSDistributedNotificationCenter.defaultCenter.objc_send(
      :addObserver, self,
         :selector, 'externalRequestForDocumentation:',
             :name, 'KariOpenDocumentation',
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
    @window.delegate = self
    @bookmarkController.delegate = self
    @searchController.delegate = self
    @webViewController.delegate = self
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
  
  # Application delegate methods
  
  def applicationDidFinishLaunching(aNotification)
    activateSearchField
  end
  
  def applicationWillTerminate(aNotification)
    PreferencesController.synchronize
    @watcher.stop
    Manager.instance.close
  end
  
  # Window delegate matehods
  
  def windowWillClose(notification)
    OSX::NSApplication.sharedApplication.terminate(self)
  end
  
  # SearchController delegate methods
  
  def searchControllerWillStartSearching
    @addBookmarkToolbarButton.enabled = false
    @searchProgressIndicator.startAnimation(self)
    
    @webView.hidden = true
    @resultsScrollView.hidden = false
  end
  
  def searchControllerFinishedSearching
    @searchProgressIndicator.stopAnimation(self)
  end
  
  def searchController_selectedFile(sender, url)
    @webViewController.load_url(url)
    @webViewController.add_search_back_forward_item(@searchTextField.stringValue)
    @webView.hidden = false
    @resultsScrollView.hidden = true
    @window.makeFirstResponder(@webView)
  end
  
  # BookmarkController delegate methods
  
  def bookmarkClicked(bookmark)
    @webViewController.load_url bookmark.url
  end
  
  # def bookmarkBarToggledVisibility(bookmarkBar)
  #   offset = (bookmarkBar.frame.height.zero? ? -OSX::SABookmarkBar::HEIGHT : OSX::SABookmarkBar::HEIGHT)
  #   p offset
  #   
  #   # move the y position of the webView and the resultsScrollView up/down, the view is flipped so subtract the offset
  #   # webView_frame = @webView.frame
  #   # @webView.frameSize = OSX::NSSize.new(webView_frame.width, webView_frame.height - offset)
  #   # 
  #   # scrollView_frame = @resultsScrollView.frame
  #   # @resultsScrollView.frameSize = OSX::NSSize.new(scrollView_frame.width, scrollView_frame.height - offset)
  #   
  #   # resize the window
  #   window_frame = @window.frame
  #   #new_size = OSX::NSSize.new(window_frame.width, window_frame.height + offset)
  #   new_size = OSX::NSSize.new(window_frame.width, window_frame.height - offset)
  #   new_origin = OSX::NSPoint.new(window_frame.x, window_frame.y + offset)
  #   #@window.setFrame_display_animate(OSX::NSRect.new(new_origin, new_size), true, true)
  #   
  #   windowRect = OSX::NSRect.new(new_origin, new_size)
  #   windowResize = { OSX::NSViewAnimationTargetKey => @window, OSX::NSViewAnimationEndFrameKey => OSX::NSValue.valueWithRect(windowRect) }
  #   
  #   bookmarkBarRect = OSX::NSRect.new(bookmarkBar.frame.origin, OSX::NSSize.new(bookmarkBar.frame.width, bookmarkBar.frame.height - offset))
  #   bookmarkBarResize = { OSX::NSViewAnimationTargetKey => bookmarkBar, OSX::NSViewAnimationEndFrameKey => OSX::NSValue.valueWithRect(bookmarkBarRect) }
  #   
  #   webView_frame = @webView.frame
  #   webViewRect = OSX::NSRect.new(webView_frame.origin, OSX::NSSize.new(webView_frame.width, webView_frame.height))
  #   webViewResize = { OSX::NSViewAnimationTargetKey => @webView, OSX::NSViewAnimationEndFrameKey => OSX::NSValue.valueWithRect(webViewRect) }
  #   
  #   scrollView_frame = @resultsScrollView.frame
  #   scrollViewRect = OSX::NSRect.new(scrollView_frame.origin, OSX::NSSize.new(scrollView_frame.width, scrollView_frame.height))
  #   scrollViewResize = { OSX::NSViewAnimationTargetKey => @resultsScrollView, OSX::NSViewAnimationEndFrameKey => OSX::NSValue.valueWithRect(scrollViewRect) }
  #   
  #   animation = OSX::NSViewAnimation.alloc.initWithViewAnimations([windowResize, bookmarkBarResize, webViewResize, scrollViewResize])
  #   animation.animationBlockingMode = OSX::NSAnimationBlocking
  #   animation.duration = 0.15
  #   animation.startAnimation
  # end
  
  def bookmarkBarToggledVisibility(bookmarkBar)
    OSX::CATransaction.begin
    #OSX::NSAnimationContext.beginGrouping
    
    offset = 21
    
    bookmarkBar_frame = bookmarkBar.frame
    #bookmarkBar.animator.frame = OSX::NSRect.new(OSX::NSPoint.new(bookmarkBar_frame.origin.x, bookmarkBar_frame.origin.y + offset), bookmarkBar.frame.size)
    #p bookmarkBar.layer
    #p bookmarkBar.layer.objc_methods.sort.grep(/frame|position/i)
    bookmarkBar.layer.position = OSX::NSPoint.new(bookmarkBar_frame.origin.x, bookmarkBar_frame.origin.y - offset)
    
    window_frame = @window.frame
    @window.animator.setFrame_display(OSX::NSRect.new(OSX::NSPoint.new(window_frame.origin.x, window_frame.origin.y + offset), OSX::NSSize.new(window_frame.width, window_frame.height - offset)), true)
    
    webView_frame = @webView.frame
    @webView.animator.frame = OSX::NSRect.new(webView_frame.origin, OSX::NSSize.new(webView_frame.width, webView_frame.height))
    
    #OSX::NSAnimationContext.endGrouping
    OSX::CATransaction.commit
  end
  
  # WebViewController delegate methods
  
  def webViewFinishedLoading(aNotification)
    @addBookmarkToolbarButton.enabled = @webViewController.bookmarkable?
    bring_webView_to_front!
  end
  
  def webView_didSelectSearchQuery(webView, query)
    @searchTextField.stringValue = query
    @searchController.search(@searchTextField)
  end
  
  private
  
  def bring_webView_to_front!
    @webView.hidden = false
    @resultsScrollView.hidden = true
  end
end