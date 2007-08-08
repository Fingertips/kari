require File.dirname(File.expand_path(__FILE__)) + "/../BookmarkController.rb"
require File.dirname(File.expand_path(__FILE__)) + "/../SABookmarkBar/SABookmarkBar.rb"

# class SABookmarkBar
# end

describe BookmarkController do
  before do
    @bookmark_controller = BookmarkController.alloc.init
    @bookmark_controller.bookmarkBar = OSX::SABookmarkBar.alloc.init
  end
  
  it "should have a reference to a SABookmarkBar instance, assign the bookmarks and set itself as it's delegate on awakeFromNib" do
    @bookmark_controller.awakeFromNib
    @bookmark_controller.bookmarkBar.should be_kind_of(OSX::SABookmarkBar)
    @bookmark_controller.bookmarkBar.delegate.should eql(@bookmark_controller)
    @bookmark_controller.bookmarkBar.instance_variable_get(:@buttons).should_not be_empty
  end
  
  it "should send clicked events to the delegate" do
    the_bookmark = mock("TheBookmark")
    the_delegate = mock("TheDelegate")
    the_delegate.should_receive(:bookmarkClicked).once.with(the_bookmark)
    @bookmark_controller.delegate = the_delegate
    @bookmark_controller.bookmarkClicked(the_bookmark)
  end
  
  def make_hashes(titles)
    hashes = []
    titles.each_with_index do |title, idx|
      hashes.push({:id => idx, :title => title, :url => "http://127.0.0.1:3301/search?q=#{title}", :order_index => idx})
    end
    return hashes
  end
  
  def make_bookmarks(titles)
    bookmarks = []
    make_hashes(titles).each do |hash|
      bookmarks.push OSX::SABookmark.alloc.initWithHash(hash)
    end
    return bookmarks
  end
  
  it "should return a predefined list of bookmarks for if there's no preference file yet and store it in the preferences" do
    OSX::NSUserDefaults.standardUserDefaults.should_receive(:objectForKey).with('Bookmarks').and_return(nil)
    OSX::NSUserDefaults.standardUserDefaults.should_receive(:setObject_forKey)
    @bookmark_controller.bookmarks.map{|b| b.title.to_s }.should eql(BookmarkController::DEFAULT_BOOKMARKS)
  end
  
  it "should return the bookmarks from the preference file if it exists" do
    titles = ['ActiveRecord', 'OSX']
    prefs_bookmarks = make_bookmarks(titles)
    OSX::NSUserDefaults.standardUserDefaults.should_receive(:objectForKey).with('Bookmarks').and_return(make_hashes(titles))
    @bookmark_controller.bookmarks.map{|b| b.title }.should eql(titles)
  end
end