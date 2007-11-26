require File.dirname(File.expand_path(__FILE__)) + "/../AppController.rb"

class OSX::NSApplication
  def self.setTheReturnMock(mock)
    @theReturnMock = mock
  end
  
  def self.sharedApplication
    @theReturnMock
  end
end

class Backend < OSX::NSObject
  def self.setTheReturnMock(mock)
    @theReturnMock = mock
  end
  def init
    self.class.instance_variable_get :@theReturnMock
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
    backend_mock.stub!(:delegate=)
    Backend.setTheReturnMock(backend_mock)
    
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
  
  it "should assign itself as the delegate for multiple controllers on awakeFromNib" do
    bookmark_controller_mock = mock("BookmarkController")
    bookmark_controller_mock.should_receive(:delegate=).once.with(@app_controller)
    @app_controller.instance_variable_set(:@bookmarkController, bookmark_controller_mock)
    
    @app_controller.instance_variable_get(:@backend).should_receive(:port).and_return(9999)
    
    webview_controller_mock = mock("WebViewController")
    webview_controller_mock.should_receive(:delegate=).with(@app_controller)
    webview_controller_mock.should_receive(:port=).with(9999)
    @app_controller.instance_variable_set(:@webViewController, webview_controller_mock)
    
    spinner_mock = mock("Spinner")
    spinner_mock.should_receive(:startAnimation).with(@app_controller)
    @app_controller.instance_variable_set(:@statusSpinner, spinner_mock)
    
    window_mock = mock("Window")
    window_mock.should_receive(:delegate=).with(@app_controller)
    @app_controller.instance_variable_set(:@window, window_mock)
    
    @app_controller.awakeFromNib
  end

  it "should change the startup status message if it's the first run and it's building the index" do
    status_label_mock = mock('Status')
    status_label_mock.should_receive(:stringValue=).with('Indexing documentation')
    @app_controller.instance_variable_set(:@statusMessage, status_label_mock)
    @app_controller.backendDidStartFirstIndexing(nil)
  end

  it "should pass a query url on to the webview controller" do
    query = "Time".to_ns
    search_field_mock = mock("SearchField")
    search_field_mock.should_receive(:stringValue).and_return(query)
    
    progress_indicator_mock = mock("Progress Indicator")
    progress_indicator_mock.should_receive(:startAnimation)
    @app_controller.instance_variable_set(:@searchProgressIndicator, progress_indicator_mock)
    
    webview_controller_mock = mock("WebViewController")
    webview_controller_mock.should_receive(:search).with(query)
    @app_controller.instance_variable_set(:@webViewController, webview_controller_mock)
    
    @app_controller.search(search_field_mock)
  end
end