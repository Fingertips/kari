require 'osx/cocoa'
require "Backend"
require "WebViewController"
OSX.require_framework 'WebKit'

class AppController < OSX::NSObject
  ib_outlets :window, :webView, :webViewController, :searchProgressIndicator, :backButton, :forwardButton, :bookmarkController, :addBookmarkSheet, :addBookmarkSheetAddButton, :bookmarkNameTextField
  
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
    @webViewController.load_url "http://127.0.0.1:9999/search?q=#{search_field.stringValue.to_s.gsub(/\s/, '+')}"
  end
  
  def home(button)
    @webViewController.load_url "http://127.0.0.1:9999"
  end
  
  def bookmark(sender)
    @bookmarkNameTextField.stringValue = @webViewController.doc_title
    #@addBookmarkSheetAddButton.highlight(true)
    OSX::NSApp.beginSheet_modalForWindow_modalDelegate_didEndSelector_contextInfo(@addBookmarkSheet, @window, self, 'addBookmarkSheetDidEnd:', nil)
  end
  def closeAddBookmarkSheet(sender)
    OSX::NSApp.endSheet @addBookmarkSheet
  end
  def addBookmarkSheetDidEnd(sender, return_code, context_info)
    @addBookmarkSheet.orderOut(self)
  end
  
  def addBookmark(sender)
    @bookmarkController.addBookmark(@bookmarkNameTextField.stringValue, @webViewController.url)
    self.closeAddBookmarkSheet(self)
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
    @backend.terminate
  end
  
end
