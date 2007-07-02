#
#  WebViewController.rb
#  Kari
#
#  Created by Eloy Duran on 7/2/07.
#  Copyright (c) 2007 __MyCompanyName__. All rights reserved.
#

require "osx/cocoa"

class WebViewController
  def initialize(webview)
    @webview = webview
  end
  
  def load_url(url)
    @webview.mainFrame.loadRequest url_request(url)
  end
  
  def url_request(url)
    OSX::NSURLRequest.requestWithURL OSX::NSURL.URLWithString(url)
  end
end
