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
  before do
    shared_app_mock = mock("sharedApplication")
    shared_app_mock.should_receive(:setDelegate).once
    OSX::NSApplication.setTheReturnMock(shared_app_mock)
    #OSX::NSApplication.stub!(:sharedApplication).and_return(shared_app_mock)

    backend_mock = mock("Backend")
    backend_mock.stub!(:launch)
    Backend.should_receive(:new).with(:no_args).and_return(backend_mock)
    
    @app_controller = AppController.alloc.init
  end
  
  it "should set itself as the application delegate and instantiate an instance of Backend on init" do
    @app_controller.should be_an_instance_of(AppController)
    @app_controller.instance_variable_get(:@backend).should_not be_nil
  end
  
  it "should terminate the running instance of Backend on application shutdown" do
    @app_controller.instance_variable_get(:@backend).should_receive(:terminate)
    @app_controller.instance_variable_get(:@backend).should_receive(:running?).and_return(false)
    
    @app_controller.applicationWillTerminate(nil)
    @app_controller.instance_variable_get(:@backend).should_not be_running
  end
  
  it "should assign itself as the delegate for the bookmark controller open the index page on awakeFromNib" do
    bookmark_controller_mock = mock("BookmarkController")
    bookmark_controller_mock.should_receive(:delegate=).once.with(@app_controller)
    @app_controller.instance_variable_set(:@bookmarkController, bookmark_controller_mock)
    
    webview_controller_mock = mock("WebViewController")
    WebViewController.stub!(:new).and_return(webview_controller_mock)
    webview_controller_mock.should_receive(:load_url).with("http://127.0.0.1:9999")
    @app_controller.awakeFromNib
  end

  it "should pass a query url on to the webview controller" do
    search_field_mock = mock("SearchField")
    search_field_mock.should_receive(:stringValue).and_return("Time".to_nsstring)
    @app_controller.instance_variable_get(:@webview_controller).should_receive(:load_url).with("http://127.0.0.1:9999/?q=Time")
    progress_indicator_mock = mock("Progress Indicator")
    progress_indicator_mock.should_receive(:startAnimation)
    @app_controller.instance_variable_set(:@searchProgressIndicator, progress_indicator_mock)
    
    @app_controller.search(search_field_mock)
  end
end