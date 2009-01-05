require File.expand_path('../../test_helper', __FILE__)

describe "BookmarkController" do
  tests BookmarkController
  
  it "should return a list of current bookmarks" do
    PreferencesController.preferences.expects(:[]).with('Bookmarks').returns([
      { :id => 0, :order_index => 1, :title => 'String', :url => 'file:///Karidoc/String.karidoc' },
      { :id => 1, :order_index => 2, :title => 'Array', :url => 'file:///Karidoc/Array.karidoc' }
    ])
    
    bookmarks = controller.bookmarks
    bookmarks.length.should == 2
    bookmarks[0].title.should == 'String'
    bookmarks[1].title.should == 'Array'
  end
end