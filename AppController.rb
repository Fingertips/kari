require 'osx/cocoa'
require "Backend"
require "WebViewController"
OSX.require_framework 'WebKit'

class AppController < OSX::NSObject
  ib_outlets :window, :webView, :webViewController, :searchProgressIndicator, :backButton, :forwardButton, :bookmarkController
  ib_outlets :statusMessage, :statusSpinner
  
  def init
    if super_init
      PreferencesController.registerDefaults
      
      @backend = Backend.alloc.init
      @backend.delegate = self
      @backend.launch
      OSX::NSApplication.sharedApplication.setDelegate(self)
      return self
    end
  end
  
  def awakeFromNib
    @statusSpinner.startAnimation(self)
    @window.delegate = self
    @webViewController.delegate = self
    @bookmarkController.delegate = self
  end
  
  def backendDidStart(sender)
    @statusSpinner.stopAnimation(self)
    @statusSpinner.hidden = true
    @statusMessage.hidden = true
    @webViewController.load_url "http://127.0.0.1:9999"
  end
  
  def search(search_field)
    @searchProgressIndicator.startAnimation(nil)
    @webViewController.load_url "http://127.0.0.1:9999/search?q=#{search_field.stringValue.to_s.gsub(/\s/, '+')}"
  end
  
  def home(button)
    @webViewController.load_url "http://127.0.0.1:9999"
  end
  
  def openPreferencesWindow(sender)
    PreferencesController.alloc.init.showWindow(self)
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
