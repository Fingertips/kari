module GlobalSpecHelper
  def make_bookmark_hashes(titles)
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