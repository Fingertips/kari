require File.expand_path('../../spec_helper', __FILE__)

module SearchControllerSpecHelper
  def self.extended(klass)
    klass.before do
      @controller = SearchController.alloc.init
      
      stub_outlets(@controller,
        :results_array_controller => FilteringArrayController.alloc.init,
        :results_table_view => ResultsTableView.alloc.init,
        :search_field => SearchField.alloc.init,
        :class_tree_controller => NSTreeController.alloc.init
      )
    end
  end
end

describe "A SearchController, when initializing" do
  extend Controllers
  extend SearchControllerSpecHelper
  
  it "should have an empty KVC accessible results array" do
    @controller.valueForKey('results').should == []
  end
end

describe "A SearchController, when awaking from nib" do
  extend Controllers
  extend SearchControllerSpecHelper
  
  before do
    @controller.awakeFromNib
  end
  
  it "should assign itself as the target for the double click action of the search results table view" do
    @results_table_view.target.should == @controller
  end
  
  it "should assign the search results table view as the key delegate for the search text field, delegating up/down arrow events" do
    @search_field.keyDelegate.should == @results_table_view
  end
end

describe "A SearchController, when performing a search" do
  extend Controllers
  extend SearchControllerSpecHelper
  
  before do
    @delegate = mock('SearchController delegate')
    @controller.delegate = @delegate
  end
  
  # DISABLED: current implementation doesn't use the manager to search
  
  # it "should send the search query, adjusted for partial string matching, to the Manager instance" do
  #   @delegate.stubs(:searchControllerWillStartSearching)
  #   Manager.instance.expects(:search).with('*a*pot*of*gold*')
  #   @controller.search('a pot of gold')
  # end
  # 
  # it "should send the search query, from the search_field, to the Manager instance" do
  #   search_field.stringValue = 'a pot of gold'
  #   Manager.instance.expects(:search).with('*a*pot*of*gold*')
  #   controller.search(search_field)
  # end
  # 
  # it "should not send the search query, from the search_field, to the Manager instance if it's empty" do
  #   search_field.stringValue = ''
  #   Manager.instance.expects(:search).never
  #   controller.search(search_field)
  # end
  # 
  # it "should not send the search query to the Manager instance if it's empty" do
  #   Manager.instance.expects(:search).never
  #   controller.search('')
  # end
  # 
  # it "should assign the search results to the `results' KVC accessor" do
  #   results = mock('Search results array')
  #   Manager.instance.stubs(:search).returns(results)
  #   controller.search('foo')
  #   controller.valueForKey('results').should.be results
  # end
  
  it "should send a notification to it's delegate when a search will commence" do
    @delegate.expects(:searchControllerWillStartSearching)
    @delegate.stubs(:searchControllerFinishedSearching)
    @controller.search('foo')
  end
  
  it "should send a notification to it's delegate when a search has finished" do
    @delegate.stubs(:searchControllerWillStartSearching)
    @delegate.expects(:searchControllerFinishedSearching)
    @controller.search('foo')
  end
end

describe "A SearchController, in general" do
  extend Controllers
  extend SearchControllerSpecHelper
  extend FixtureHelpers
  
  before do
    @delegate = mock('SearchController delegate')
    @controller.delegate = @delegate
    
    @urls = [
      NSURL.fileURLWithPath('/Karidoc/Mutex/dup.karidoc'),
      NSURL.fileURLWithPath('/Karidoc/Mutex/try_lock.karidoc')
    ]
    @matches = [
      Match.alloc.initWithURL(@urls.first, score: 1.2345),
      Match.alloc.initWithURL(@urls.last, score: 2.3456)
    ]
    @results_array_controller.content = @matches
    
    @controller.awakeFromNib
  end
  
  it "should make the results_array_controller sort by relevance score" do
    @results_array_controller.arrangedObjects.should == @matches.reverse
  end
  
  # DISABLED: need to figure out how this is supposed to work first
  # it "should tell its delegate that a specific search result was chosen" do
  #   @results_table_view.stubs(:selectedRow).returns(0)
  #   @delegate.expects(:searchController_selectedFile).with do |search_controller, matched_url|
  #     search_controller == @controller and matched_url.path[-@urls.last.path.length..-1] == @urls.last.path
  #   end
  #   @controller.rowDoubleClicked(@results_table_view)
  # end
end