require 'osx/cocoa'
#require "Backend"

require File.expand_path("../WebViewController", __FILE__)
require File.expand_path('../PreferencesController', __FILE__)
OSX.require_framework 'WebKit'

class AppController < OSX::NSObject
  ib_outlet :window
  ib_outlet :webView
  ib_outlet :webViewController
  ib_outlet :searchProgressIndicator
  ib_outlet :searchTextField
  ib_outlet :backButton
  ib_outlet :forwardButton
  ib_outlet :bookmarkController
  ib_outlet :statusMessage
  ib_outlet :statusSpinner
  
  def init
    if super_init
      PreferencesController.registerDefaults
      setupBackend
      OSX::NSApplication.sharedApplication.setDelegate(self)
      return self
    end
  end
  
  def setupBackend
    @backend = Backend.alloc.init
    @backend.delegate = self
    @backend.launch
  end
  
  def showStatus
    @webViewController.blank
    @statusSpinner.startAnimation(self)
    @statusMessage.stringValue = 'Starting'
    @statusSpinner.hidden = false
    @statusMessage.hidden = false
  end
  
  def awakeFromNib
    @window.makeFirstResponder(@searchTextField)
    
    @statusSpinner.startAnimation(self)
    
    OSX::NSDistributedNotificationCenter.defaultCenter.objc_send(
      :addObserver, self,
         :selector, 'externalRequestForDocumentation:',
             :name, 'KariOpenDocumentation',
           :object, nil
    )
    
    @window.delegate = self
    @bookmarkController.delegate = self
    @webViewController.delegate = self
  end
  
  def search(search_field)
    @searchProgressIndicator.startAnimation(nil)
    @webViewController.search search_field.stringValue.to_s
  end
  
  def home(button)
    @webViewController.home
  end
  
  def openPreferencesWindow(sender)
    PreferencesController.alloc.init.showWindow(self)
  end
  
  def rebuildIndex(sender)
    @backend.terminate
    showStatus
    Backend.removeIndex
    setupBackend
  end
  
  def externalRequestForDocumentation(aNotification)
    query = aNotification.userInfo['query']
    @webViewController.search(query) unless query.nil? || query.empty?
  end
  
  # Backend delegate methods
  
  def backendDidStartFirstIndexing(sender)
    @statusMessage.stringValue = 'Indexing documentation'
  end
  
  def backendDidStart(sender)
    @webViewController.port = @backend.port
    @statusSpinner.stopAnimation(self)
    @statusSpinner.hidden = true
    @statusMessage.hidden = true
    @webViewController.home
  end
  
  # Window delegate matehods
  
  def windowWillClose(aNotification)
    OSX::NSApplication.sharedApplication.terminate(self)
  end
  
  # BookmarController delegate methods
  
  def bookmarkClicked(bookmark)
    @webViewController.load_url bookmark.url
  end
  
  # WebViewController delegate methods
  
  def webViewFinishedLoading(aNotification)
    @window.title = @webViewController.doc_title unless @webViewController.doc_title.nil?
    @searchProgressIndicator.stopAnimation(nil)
    @backButton.enabled = @webViewController.can_go_back?
    @forwardButton.enabled = @webViewController.can_go_forward?
  end
  
  # Application delegate methods
  
  def applicationDidFinishLaunching(aNotification)
  end
  
  def applicationWillTerminate(aNotification)
    PreferencesController.synchronize
    @backend.terminate
  end
  
end
