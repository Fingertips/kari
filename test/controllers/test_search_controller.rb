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
  
  it "should send the search query, from the search_field, to the Manager instance" do
    search_field.stringValue = 'a pot of gold'
    Manager.instance.expects(:search).with('a pot of gold')
    controller.search(search_field)
  end
  
  ['a pot of gold', 'a pot of gold'.to_ns].each do |query|
    it "should send the search query, passed as a #{query.class.name}, to the Manager instance" do
      Manager.instance.expects(:search).with(query)
      controller.search(query)
    end
  end
  
  it "should not send the search query, from the search_field, to the Manager instance if it's empty" do
    search_field.stringValue = ''
    Manager.instance.expects(:search).never
    controller.search(search_field)
  end
  
  ['', ''.to_ns].each do |query|
    it "should not send the search query, passed as a #{query.class.name}, to the Manager instance if it's empty" do
      Manager.instance.expects(:search).never
      controller.search(query)
    end
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
  end
  
  it "should tell its delegate that a specific search result was chosen" do
    url1 = OSX::NSURL.fileURLWithPath(file_fixture('Karidoc/Mutex/dup.karidoc'))
    url2 = OSX::NSURL.fileURLWithPath(file_fixture('Karidoc/Mutex/try_lock.karidoc'))
    match1 = SearchKit::Match.alloc.initWithURL_score(url1, 1.2345)
    match2 = SearchKit::Match.alloc.initWithURL_score(url2, 2.3456)
    
    results_array_controller.content = [match1, match2]
    results_table_view.stubs(:selectedRow).returns(1)
    
    @delegate.expects(:searchController_selectedFile).with do |search_controller, matched_url|
      search_controller == controller and matched_url.path == url2.path
    end
    
    controller.rowDoubleClicked(results_table_view)
  end
end

# describe 'SearchController' do
#   before do
#     @controller = SearchController.alloc.init
#   end
# 
#   it "should send a result selected event to its delegate with a file path" do
#     result = mock("MetaData Result Item")
#     result.stubs(:valueForAttribute).returns('/some/file.karidoc'.to_ns)
#     results = [result]
#     
#     tableView_mock = mock("Results TablView")
#     tableView_mock.stubs(:selectedRow => 0)
#     
#     metadata_array_controller_mock = mock("MetaData Array Controller")
#     metadata_array_controller_mock.expects(:arrangedObjects).returns(results)
#     assigns(:metadata_array_controller, metadata_array_controller_mock)
#     
#     delegate_mock = mock("Delegate")
#     delegate_mock.expects(:searchController_selectedFile).with(@controller, '/some/file.karidoc')
#     assigns(:delegate, delegate_mock)
#     
#     @controller.rowDoubleClicked(tableView_mock)
#   end
#   
#   FULL_NAME = 'com_fngtps_kari_karidoc_fullName'
#   
#   it "should search for text like the full name" do
#     assigns(:search_string, 'foo')
#     query.should == "((#{FULL_NAME} LIKE[wcd] 'foo*') || (#{FULL_NAME} LIKE[c] '*f*o*o*'))"
#   end
#   
#   private
#   
#   def query
#     @controller.send(:query)
#   end
#   
#   def assigns(name, value = nil)
#     @controller.assigns(name, value)
#   end
# end