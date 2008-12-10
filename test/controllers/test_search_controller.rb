require File.expand_path('../../test_helper', __FILE__)

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