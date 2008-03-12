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
  
  def after_init
    PreferencesController.registerDefaults
    OSX::NSApplication.sharedApplication.setDelegate(self)
  end
  
  def awakeFromNib
    OSX::NSDistributedNotificationCenter.defaultCenter.objc_send(
      :addObserver, self,
         :selector, 'externalRequestForDocumentation:',
             :name, 'KariOpenDocumentation',
           :object, nil
    )
    
    @window.delegate = self
    @bookmarkController.delegate = self
    @searchController.delegate = self
    @webViewController.delegate = self
    @webViewController.home!
  end
  
  def externalRequestForDocumentation(notification)
    query = notification.userInfo['query']
    #@webViewController.search(query) unless query.nil? || query.empty?
    @searchController.search(query) unless query.nil? || query.empty?
  end
  
  def openPreferencesWindow(sender)
    PreferencesController.alloc.init.showWindow(self)
  end
  
  def rebuildIndex(sender)
    log.debug 'Need to implement rebuildIndex method.'
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
    @webViewController.blank!
    @resultsScrollView.hidden = false
  end
  
  def searchControllerFinishedSearching
    @searchProgressIndicator.stopAnimation(self)
  end
  
  def searchController_selectedFile(sender, file)
    @webViewController.load_file(file)
    @webView.hidden = false
    @resultsScrollView.hidden = true
    @window.makeFirstResponder(@webView)
  end
  
  # BookmarkController delegate methods
  
  def bookmarkClicked(bookmark)
    @webViewController.load_url bookmark.url
  end
  
  # WebViewController delegate methods
  
  def webViewFinishedLoading(aNotification)
    @addBookmarkToolbarButton.enabled = @webViewController.bookmarkable?
  end
end