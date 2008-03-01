class ApplicationController < Rucola::RCController
  ib_outlet :window
  ib_outlet :webView
  ib_outlet :webViewController
  ib_outlet :searchController
  ib_outlet :searchProgressIndicator
  ib_outlet :searchTextField
  ib_outlet :bookmarkController
  ib_outlet :statusMessage
  ib_outlet :statusSpinner
  ib_outlet :resultsScrollView
  
  def after_init
    PreferencesController.registerDefaults
    OSX::NSApplication.sharedApplication.setDelegate(self)
  end
  
  def showStatus
    @webViewController.blank
    @statusSpinner.startAnimation(self)
    @statusMessage.stringValue = 'Starting'
    @statusSpinner.hidden = false
    @statusMessage.hidden = false
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
    @webViewController.home
    
    @window.makeFirstResponder(@searchTextField)
  end
  
  # def search(search_field)
  #   #@search_controller.search(search_field.stringValue)
  #   
  #   @searchProgressIndicator.startAnimation(nil)
  #   #@webViewController.search search_field.stringValue.to_s
  # end
  
  def openPreferencesWindow(sender)
    PreferencesController.alloc.init.showWindow(self)
  end
  
  # def rebuildIndex(sender)
  #   @backend.terminate
  #   showStatus
  #   Backend.removeIndex
  #   setupBackend
  # end
  
  def externalRequestForDocumentation(aNotification)
    query = aNotification.userInfo['query']
    @webViewController.search(query) unless query.nil? || query.empty?
  end
  
  # # Backend delegate methods
  # 
  # def backendDidStartFirstIndexing(sender)
  #   @statusMessage.stringValue = 'Indexing documentation'
  # end
  # 
  # def backendDidStart(sender)
  #   @webViewController.port = @backend.port
  #   @statusSpinner.stopAnimation(self)
  #   @statusSpinner.hidden = true
  #   @statusMessage.hidden = true
  #   @webViewController.home
  # end
  
  # Window delegate matehods
  
  def windowWillClose(notification)
    OSX::NSApplication.sharedApplication.terminate(self)
  end
  
  # SearchController delegate methods
  
  def searchControllerWillStartSearching
    @searchProgressIndicator.startAnimation(self)
    @webView.hidden = true
    @webViewController.blank
    @resultsScrollView.hidden = false
  end
  
  def searchControllerFinishedSearching
    @searchProgressIndicator.stopAnimation(self)
  end
  
  def searchController_selectedURL(sender, url)
    @webViewController.load_url url
    @webView.hidden = false
    @resultsScrollView.hidden = true
  end
  
  # BookmarkController delegate methods
  
  def bookmarkClicked(bookmark)
    @webViewController.load_url bookmark.url
  end
  
  # WebViewController delegate methods
  
  def webViewFinishedLoading(aNotification)
    # R159: No more window title for the specific doc.
    #@window.title = @webViewController.doc_title unless @webViewController.doc_title.nil?
    #@searchProgressIndicator.stopAnimation(nil)
  end
  
  # Application delegate methods
  
  def applicationDidFinishLaunching(aNotification)
  end
  
  def applicationWillTerminate(aNotification)
    PreferencesController.synchronize
  end
end