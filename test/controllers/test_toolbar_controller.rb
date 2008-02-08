require File.expand_path('../../test_helper', __FILE__)

describe 'ToolbarController' do
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
    window_mock.should_receive(:showsToolbarButton=).with false
    #toolbar_button_mock = mock("Toolbar Button")
    #toolbar_button_mock.should_receive(:removeFromSuperview)
    #border_view_mock = mock("_BorderView")
    #border_view_mock.should_receive(:toolbarButton).and_return(toolbar_button_mock)
    #window_mock.should_receive(:_borderView).and_return(border_view_mock)
    
    @toolbar_controller.instance_variable_set(:@window, window_mock)
    @toolbar_controller.awakeFromNib
  end
  
  it "should return allowed/default toolbar item identifiers" do
    items = ['HistoryBackAndForwardItem', 'FontSmallerAndBiggerItem', 'HomeItem', 'AddBookmarkItem', OSX::NSToolbarFlexibleSpaceItemIdentifier, 'SearchItem']
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