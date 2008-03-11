require File.expand_path('../../test_helper', __FILE__)

# Need to get at the defined ib_outlets and setup mocks for each one.
class OSX::NSObject
  def assigns(name, value = nil)
    if value.nil?
      instance_variable_get("@#{name}".to_sym)
    else
      instance_variable_set("@#{name}", value)
    end
  end
end

describe 'SearchController' do
  before do
    @controller = SearchController.alloc.init
  end

  it "should send a result selected event to its delegate with a file path" do
    result = mock("MetaData Result Item")
    result.stubs(:valueForAttribute).returns('/some/file.karidoc'.to_ns)
    results = [result]
    
    tableView_mock = mock("Results TablView")
    tableView_mock.stubs(:selectedRow => 0)
    
    metadata_array_controller_mock = mock("MetaData Array Controller")
    metadata_array_controller_mock.expects(:arrangedObjects).returns(results)
    assigns(:metadata_array_controller, metadata_array_controller_mock)
    
    delegate_mock = mock("Delegate")
    delegate_mock.expects(:searchController_selectedFile).with(@controller, '/some/file.karidoc')
    assigns(:delegate, delegate_mock)
    
    @controller.rowDoubleClicked(tableView_mock)
  end
  
  private
  
  def assigns(name, value = nil)
    @controller.assigns(name, value)
  end
end