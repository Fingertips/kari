require 'osx/cocoa'
require "Backend"
require "WebViewController"
OSX.require_framework 'WebKit'

class AppController < OSX::NSObject
  ib_outlets :window, :webView, :webViewController, :searchProgressIndicator, :backButton, :forwardButton, :bookmarkController, :addBookmarkPanel, :bookmarkNameTextField
  
  def init
    if super_init
      @backend = Backend.new
      @backend.launch
      OSX::NSApplication.sharedApplication.setDelegate(self)
      return self
    end
  end
  
  def awakeFromNib
    OSX::NSNotificationCenter.defaultCenter.objc_send :addObserver, self,
                                                      :selector,    'windowWillClose:',
                                                      :name,        OSX::NSWindowWillCloseNotification,
                                                      :object,      nil
    
    @webViewController.delegate = self
    @bookmarkController.delegate = self
    
    #sleep 5 # FIXME: ugly, but just for now
    @webViewController.load_url "http://127.0.0.1:9999"
  end
  
  def search(search_field)
    @searchProgressIndicator.startAnimation(nil)
    @webViewController.load_url "http://127.0.0.1:9999/search?q=#{search_field.stringValue.to_s}"
  end
  
  def home(button)
    @webViewController.load_url "http://127.0.0.1:9999"
  end
  
  def bookmark(sender)
    puts 'bookmark'
    @addBookmarkPanel.makeKeyAndOrderFront(self)
  end
  
  def addBookmark(sender)
    bookmark_name = @bookmarkNameTextField.stringValue
    url = @webViewController.url
    @bookmarkController.addBookmark(bookmark_name, url)
  end
  
  # Window delegate matehods
  
  def windowWillClose(aNotification)
    OSX::NSApplication.sharedApplication.terminate(self)
  end
  
  # BookmarController delegate methods
  
  def bookmarkClicked(bookmark)
    puts '', "Bookmark clicked: #{bookmark.title}", bookmark.url
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
    @backend.terminate
  end
  
end
