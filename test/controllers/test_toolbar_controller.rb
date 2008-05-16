require File.expand_path('../../test_helper', __FILE__)

# describe 'ToolbarController' do
#   before do
#     @toolbar_controller = ToolbarController.alloc.init
#   end
#   
#   it "should setup a NSToolbar instance" do
#     OSX::NSToolbar.any_instance.expects(:delegate=).with(@toolbar_controller)
#     OSX::NSToolbar.any_instance.expects(:displayMode=).with(OSX::NSToolbarDisplayModeIconOnly)
#     @toolbar_controller.after_init
#   end
#   
#   it "should assign it's toolbar to the window" do
#     window_mock = mock("Main Window")
#     window_mock.expects(:toolbar=).with @toolbar_controller.instance_variable_get(:@toolbar)
#     window_mock.expects(:showsToolbarButton=).with false
#     #toolbar_button_mock = mock("Toolbar Button")
#     #toolbar_button_mock.expects(:removeFromSuperview)
#     #border_view_mock = mock("_BorderView")
#     #border_view_mock.expects(:toolbarButton).and_return(toolbar_button_mock)
#     #window_mock.expects(:_borderView).and_return(border_view_mock)
#     
#     @toolbar_controller.instance_variable_set(:@window, window_mock)
#     @toolbar_controller.awakeFromNib
#   end
#   
#   it "should return allowed/default toolbar item identifiers" do
#     items = ['HistoryBackAndForwardItem', 'HomeItem', 'AddBookmarkItem', OSX::NSToolbarFlexibleSpaceItemIdentifier, 'SearchItem']
#     @toolbar_controller.toolbarAllowedItemIdentifiers(nil).should == items
#     @toolbar_controller.toolbarDefaultItemIdentifiers(nil).should == items
#   end
#   
#   it "should setup a NSToolbarItem for a given identifier" do
#     id = "HistoryBackAndForwardItem"
#     custom_view_rect = OSX::NSMakeRect(0,0,100,100)
#     @toolbar_controller.ib_outlet(:historyBackAndForwardView).expects(:frame).times(2).returns(custom_view_rect)
#     
#     item = @toolbar_controller.toolbar_itemForItemIdentifier_willBeInsertedIntoToolbar(nil, id, nil)
#     item.itemIdentifier.should == id
#     item.minSize.should == OSX::NSMakeSize(100,100)
#     item.maxSize.should == OSX::NSMakeSize(100,100)
#   end
# end