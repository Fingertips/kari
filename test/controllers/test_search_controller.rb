require File.expand_path('../../test_helper', __FILE__)

describe "A SearchController, when initializing" do
  tests SearchController
  
  it "should have an empty KVC accessible results array" do
    controller.valueForKey('results').should == [].to_ns
  end
end

describe "A SearchController, when awaking from nib" do
  tests SearchController
  
  def after_setup
    ib_outlets :results_table_view => OSX::NSTableView.alloc.init,
               :search_field => SearchField.alloc.init
    
    controller.awakeFromNib
  end
  
  it "should assign itself as the target for the double click action of the search results table view" do
    results_table_view.target.should == controller
    results_table_view.doubleAction.should == 'rowDoubleClicked:'
  end
  
  it "should assign the search results table view as the key delegate for the search text field, delegating up/down arrow events" do
    search_field.keyDelegate.should == results_table_view
  end
end

describe "A SearchController, when performing a search" do
  tests SearchController
  
  def after_setup
    ib_outlets :search_field => SearchField.alloc.init
    @delegate = stub_everything('SearchController delegate')
    controller.delegate = @delegate
  end
  
  it "should send the search query, adjusted for partial string matching, to the Manager instance" do
    Manager.instance.expects(:search).with('*a*pot*of*gold*')
    controller.search('a pot of gold')
  end
  
  it "should send the search query, from the search_field, to the Manager instance" do
    search_field.stringValue = 'a pot of gold'
    Manager.instance.expects(:search).with('*a*pot*of*gold*')
    controller.search(search_field)
  end
  
  it "should not send the search query, from the search_field, to the Manager instance if it's empty" do
    search_field.stringValue = ''
    Manager.instance.expects(:search).never
    controller.search(search_field)
  end
  
  it "should not send the search query to the Manager instance if it's empty" do
    Manager.instance.expects(:search).never
    controller.search('')
  end
  
  it "should assign the search results to the `results' KVC accessor" do
    results = mock('Search results array')
    Manager.instance.stubs(:search).returns(results)
    controller.search('foo')
    controller.valueForKey('results').should.be results
  end
  
  it "should send a notification to it's delegate when a search will commence" do
    @delegate.expects(:searchControllerWillStartSearching)
    controller.search('foo')
  end
  
  it "should send a notification to it's delegate when a search has finished" do
    @delegate.expects(:searchControllerFinishedSearching)
    controller.search('foo')
  end
end

describe "A SearchController, in general" do
  tests SearchController
  
  include FixtureHelpers
  
  def after_setup
    ib_outlets :results_table_view => OSX::NSTableView.alloc.init,
               :results_array_controller => OSX::NSArrayController.alloc.init
    
    @delegate = stub_everything('SearchController delegate')
    controller.delegate = @delegate
    
    @urls = [
      OSX::NSURL.fileURLWithPath(file_fixture('Karidoc/Mutex/dup.karidoc')),
      OSX::NSURL.fileURLWithPath(file_fixture('Karidoc/Mutex/try_lock.karidoc'))
    ]
    @matches = [
      SearchKit::Match.alloc.initWithURL_score(@urls.first, 1.2345),
      SearchKit::Match.alloc.initWithURL_score(@urls.last, 2.3456)
    ]
    results_array_controller.content = @matches
    
    controller.awakeFromNib
  end
  
  it "should make the results_array_controller sort by relevance score" do
    results_array_controller.arrangedObjects.should == @matches.reverse
  end
  
  it "should tell its delegate that a specific search result was chosen" do
    results_table_view.stubs(:selectedRow).returns(0)
    @delegate.expects(:searchController_selectedFile).with do |search_controller, matched_url|
      search_controller == controller and matched_url.path == @urls.last.path
    end
    controller.rowDoubleClicked(results_table_view)
  end
end