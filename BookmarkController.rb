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
    # just some temp items
    labels = ['String', 'String', 'Symbol', 'Proc', 'Numeric', 'Hash', 'ActiveRecord', 'ActiveSupport', 'ActionPack']
    bookmarks = []
    labels.each_with_index do |label, idx|
      bookmarks.push OSX::SABookmark.alloc.initWithHash({:id => idx, :title => label, :url => "http://127.0.0.1:3301/search?q=#{label}", :order_index => idx})
    end
    @bookmarkBar.bookmarks = bookmarks
    @bookmarkBar.delegate = self
  end
  
  def bookmarkClicked(bookmark)
    @delegate.bookmarkClicked(bookmark)
  end
end
