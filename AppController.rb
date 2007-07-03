#
#  AppController.rb
#  Kari
#
#  Created by Eloy Duran on 7/2/07.
#  Copyright (c) 2007 __MyCompanyName__. All rights reserved.
#

require 'osx/cocoa'
require "CampKari"
require "WebViewController"
OSX.require_framework 'WebKit'

class AppController < OSX::NSObject
  ib_outlets :webView, :searchProgressIndicator, :backButton, :forwardButton
  
  def init
    if super_init
      @camp_kari = CampKari.new
      @camp_kari.launch
      OSX::NSApplication.sharedApplication.setDelegate(self)
      return self
    end
  end
  
  def awakeFromNib
    @webview_controller = WebViewController.new(@webView)
    sleep 5 # FIXME: ugly, but just for now
    @webview_controller.load_url "http://127.0.0.1:3301"
  end
  
  def search(search_field)
    @searchProgressIndicator.startAnimation(nil)
    @webview_controller.load_url "http://127.0.0.1:3301/?q=#{search_field.stringValue.to_s}"
  end
  
  def home(button)
    @webview_controller.load_url "http://127.0.0.1:3301"
  end
  
  def bookmark(sender)
    puts 'bookmark'
  end
  
  def webViewFinishedLoading(aNotification)
    @searchProgressIndicator.stopAnimation(nil)
    @backButton.enabled = @webview_controller.can_go_back?
    @forwardButton.enabled = @webview_controller.can_go_forward?
  end
  
  def applicationDidFinishLaunching(aNotification)
    OSX::NSNotificationCenter.defaultCenter.objc_send :addObserver, self,
                                                      :selector,    'webViewFinishedLoading:',
                                                      :name,        OSX::WebViewProgressFinishedNotification,
                                                      :object,      nil
  end
  
  def applicationWillTerminate(aNotification)
    @camp_kari.terminate
  end
  
end
