require File.dirname(File.expand_path(__FILE__)) + "/../ToolbarController.rb"

describe ToolbarController do
  before do
    @toolbar_controller = ToolbarController.alloc.init
  end
  
  it "should setup a NSToolbar instance" do
    controller = ToolbarController.alloc.init
    controller.instance_variable_get(:@toolbar).should be_instance_of(OSX::NSToolbar)
    controller.instance_variable_get(:@toolbar).delegate.should == controller
  end
  
  it "should assign it's toolbar to the window" do
    window_mock = mock("Main Window")
    window_mock.should_receive(:toolbar=).with @toolbar_controller.instance_variable_get(:@toolbar)
    @toolbar_controller.instance_variable_set(:@window, window_mock)
    @toolbar_controller.awakeFromNib
  end
  
  it "should return allowed/default toolbar item identifiers" do
    items = ['HistoryBackAndForwardItem', 'FontSmallerAndBiggerItem', OSX::NSToolbarFlexibleSpaceItemIdentifier, 'SearchItem']
    @toolbar_controller.toolbarAllowedItemIdentifiers(nil).should == items
    @toolbar_controller.toolbarDefaultItemIdentifiers(nil).should == items
  end
  
  it "should setup a NSToolbarItem for a given identifier" do
    id = "HistoryBackAndForwardItem"
    custom_view_rect = OSX::NSMakeRect(0,0,100,100)
    view_mock = mock("@historyBackAndForwardView")
    view_mock.should_receive(:frame).twice.and_return(custom_view_rect)
    @toolbar_controller.instance_variable_set(:@historyBackAndForwardView, view_mock)
    
    item = @toolbar_controller.toolbar_itemForItemIdentifier_willBeInsertedIntoToolbar(nil, id, nil)
    item.itemIdentifier.should == id
    item.view.should == view_mock
    item.minSize.should == OSX::NSMakeSize(100,100)
    item.maxSize.should == OSX::NSMakeSize(100,100)
  end
end
