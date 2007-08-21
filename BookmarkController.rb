#
#  BookmarkController.rb
#  Kari
#
#  Created by Eloy Duran on 8/6/07.
#  Copyright (c) 2007 __MyCompanyName__. All rights reserved.
#

require 'osx/cocoa'

class BookmarkController < OSX::NSObject
  ib_outlet :bookmarkBar
  attr_accessor :bookmarkBar, :delegate
  
  def awakeFromNib
    @bookmarkBar.bookmarks = self.bookmarks
    @bookmarkBar.delegate = self
  end
  
  def bookmarks
    @bookmarks ||= self.get_bookmarks
  end
  
  DEFAULT_BOOKMARKS = ['Object', 'String', 'Array', 'Hash', 'Numeric']
  def get_bookmarks
    unless hash_bookmarks = OSX::NSUserDefaults.standardUserDefaults.objectForKey('Bookmarks')
      hash_bookmarks = []
      DEFAULT_BOOKMARKS.each_with_index do |title, idx|
        hash_bookmarks.push({:id => idx, :title => title, :url => "http://127.0.0.1:9999/search?q=#{title}", :order_index => idx})
      end
      # store the standard bookmarks in the preference file
      OSX::NSUserDefaults.standardUserDefaults.setObject_forKey(hash_bookmarks, 'Bookmarks')
    end
    return hash_bookmarks.map {|h| OSX::SABookmark.alloc.initWithHash(h) }
  end
  
  def bookmarkClicked(bookmark)
    @delegate.bookmarkClicked(bookmark)
  end
end
