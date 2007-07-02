require File.dirname(File.expand_path(__FILE__)) + "/../AppController.rb"

class OSX::NSApplication
  def self.setTheReturnMock(mock)
    @theReturnMock = mock
  end
  
  def self.sharedApplication
    @theReturnMock
  end
end

describe AppController do
  it "should set itself as the application delegate and instantiate a CampKari on init" do
    shared_app_mock = mock("sharedApplication")
    shared_app_mock.should_receive(:setDelegate).once
    OSX::NSApplication.setTheReturnMock(shared_app_mock)
    #OSX::NSApplication.stub!(:sharedApplication).and_return(shared_app_mock)
    
    app_controller = AppController.alloc.init
    app_controller.should be_an_instance_of(AppController)
    
    app_controller.instance_variable_get(:@camp_kari).should_not be_nil
    app_controller.instance_variable_get(:@camp_kari).terminate
  end
end