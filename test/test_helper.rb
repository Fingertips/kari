ENV['RUBYCOCOA_ENV'] = 'test'
ENV['RUBYCOCOA_ROOT'] = File.expand_path('../../', __FILE__)

require 'rubygems'
require 'test/unit'
require 'test/spec'
require 'mocha'
require 'rucola'
require 'rucola/test_helper'

require File.expand_path('../../config/boot', __FILE__)

def silence_warnings
  old_verbose, $VERBOSE = $VERBOSE, nil
  yield
ensure
  $VERBOSE = old_verbose
end

module GlobalSpecHelper
  def make_hashes(titles)
    hashes = []
    titles.each_with_index do |title, idx|
      hashes.push({:id => idx, :title => title, :url => "http://127.0.0.1:10002/show/#{title}", :order_index => idx})
    end
    hashes
  end
  
  def make_bookmarks(titles)
    bookmarks = []
    make_hashes(titles).each do |hash|
      bookmarks.push OSX::SABookmark.alloc.initWithHash(hash)
    end
    bookmarks
  end
end