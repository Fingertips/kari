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
  ib_outlets :webView, :searchProgressIndicator
  
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
  
  def applicationWillTerminate(aNotification)
    puts 'quit'
    @camp_kari.terminate
  end
  
end
