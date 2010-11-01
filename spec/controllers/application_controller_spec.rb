require File.expand_path('../../spec_helper', __FILE__)

class ApplicationController
  # Directly apply the frame instead of animating, so we can use assert_difference.
  def animate(views)
    views.each { |view, frame| view.frame = frame }
  end
end

module ApplicationControllerSpecHelper
  def self.extended(instance)
    instance.before do
      @controller = ApplicationController.alloc.init
      
      stub_outlets(@controller,
        :webViewController       => WebViewController.alloc.init,
        :webView                 => WebView.alloc.init,
        :resultsScrollView       => NSScrollView.alloc.init,
        :searchTextField         => NSSearchField.alloc.init,
        :classTreeController     => NSTreeController.alloc.init,
        :searchController        => SearchController.alloc.init,
        :splitView               => NSSplitView.alloc.init,
        :window                  => NSWindow.alloc.init,
        :searchProgressIndicator => mock('Progress Indicator', :startAnimation => nil, :stopAnimation => nil)
      )
      
      @webViewController.webview = @webView
      @webViewController.stubs(:load_file)
      
      @searchTextField.stringValue = 'ActiveRecord'
      
      @manager_mock = mock('Manager')
      @manager_mock.stubs(:namespace).returns([])
      @manager_mock.stubs(:examine)
      @manager_mock.stubs(:descriptions).returns([])
      
      Manager.stubs(:instance).returns(@manager_mock)
      Manager.stubs(:bootstrap)
      Manager.stubs(:cleanup)
      Manager.stubs(:first_run?).returns(false)
      
      @watcher_mock = mock('Watcher')
      @watcher_mock.stubs(:delegate=)
      @watcher_mock.stubs(:start)
      def @watcher_mock.init; self; end
      Watcher.stubs(:alloc).returns(@watcher_mock)
      
      @namespace_mock = stub('Manager#namespace')
      @namespace_mock.stubs(:tree).returns({})
      @manager_mock.stubs(:namespace).returns(@namespace_mock)
      
      NSTimer.stubs(:scheduledTimerWithTimeInterval)
      
      @controller.stubs(:setup_splitView!)
    end
    
    def should_observe_notification(name, selector, object = nil, observer = nil)
      observer ||= @controller
      NSNotificationCenter.defaultCenter.expects(:addObserver_selector_name_object).with(observer, selector, name, object)
    end
  end
  
  def should_bring_webView_to_front
    @webView.hidden = true
    @resultsScrollView.hidden = false
    yield
    @webView.hidden?.should.be false
    @resultsScrollView.hidden?.should.be true
  end
  
  def load_url!(file = nil)
    @controller.searchController_selectedFile(nil, file)
  end
end

# describe 'ApplicationController, during awakeFromNib' do
#   extend Controllers
#   extend FixtureHelpers
#   extend ApplicationControllerSpecHelper
#   
#   # DISABLED: was already disabled when I started porting
#   # it "should setup the splitView so the top is hidden if necessary" do
#   #   controller.expects(:setup_splitView!)
#   #   controller.awakeFromNib
#   # end
#   
#   it "should set the correct default kvc values" do
#     @controller.stubs(:buildIndex)
#     @controller.awakeFromNib
#     
#     @controller.processing.should == 0
#     @controller.class_tree.should == []
#   end
#   
#   it "should initialize a Manager instance" do
#     Manager.expects(:instance).returns(@manager_mock)
#     @controller.awakeFromNib
#   end
#   
#   it "should set itself as the delegate of the watcher" do
#     @watcher_mock.expects(:delegate=).with(@controller)
#     @controller.awakeFromNib
#   end
#   
#   # DISABLED: defaultCenter doesn't appear to want to expect stuff
#   # it "should register for notifications" do
#   #   NSDistributedNotificationCenter.defaultCenter.expects(:addObserver).with(@controller, { selector: 'externalRequestForDocumentation:', name: 'KariOpenDocumentation', object: nil})
#   #   @controller.awakeFromNib
#   # end
#   
#   # DISABLED: NSTimer doesn't appear to want to expect stuff
#   # it "should set a scheduled timer to signal the watcher" do
#   #   NSTimer.expects(:scheduledTimerWithTimeInterval).with(5, target: @watcher_mock, selector: 'signal:', userInfo: nil, repeats: true)
#   #   @controller.awakeFromNib
#   # end
#   
#   it "should bootstrap the manager on first run" do
#     Manager.expects(:first_run?).returns(true)
#     Manager.expects(:bootstrap)
#     @controller.awakeFromNib
#   end
# end

# describe "ApplicationController, when dealing with the positioning of the splitView" do
#   extend Controllers
#   extend AssertDifferenceAssertions
#   extend ApplicationControllerSplitViewSpecHelper
#   
#   before do
#     @controller = ApplicationController.alloc.init
#     stub_outlets(@controller,
#       :classBrowser => NSBrowser.alloc.initWithFrame([0, 200, 200, 100]),
#       :splitView    => SplitViewWithDisableableDivider.alloc.initWithFrame([0, 20, 200, 280]),
#       :window       => NSWindow.alloc.init
#     )
#     
#     @window.stubs(:contentView).returns(NSView.alloc.initWithFrame(NSRect.new(0, 0, 200, 200)))
#     
#     @splitView.vertical = false
#     @splitView.addSubview NSView.alloc.initWithFrame([0, 0, 200, 100]) # top
#     @splitView.addSubview NSView.alloc.initWithFrame([0, 109, 200, 180]) # bottom
#     @splitView.stubs(:super_resetCursorRects)
#     
#     preferences['interface.class_browser_height'] = @classBrowser.frame.height
#   end
#   
#   it "should make the split view span the complete content view of the window, minus the status bar, when the `toggle class browser' button state is turned on" do
#     preferences['interface.class_browser_visible'] = true
#     
#     #assert_difference("splitView.frame.height", -classBrowser.frame.height) do
#       assert_no_difference('controller.topViewOfSplitView.frame.height') do
#         #assert_difference("controller.bottomViewOfSplitView.frame.height", -(classBrowser.frame.height + splitView.dividerThickness)) do
#           controller.toggleClassBrowser(nil)
#         #end
#       end
#     #end
#   end
#   
#   it "should only show the bottom part of the split view when the `toggle class browser' button state is turned off" do
#     preferences['interface.class_browser_visible'] = false
#     controller.toggleClassBrowser(nil)
#     
#     assert_difference('splitView.frame.height', +(classBrowser.frame.height + splitView.dividerThickness)) do
#       #assert_no_difference('controller.topViewOfSplitView.frame.height') do
#         assert_difference('controller.bottomViewOfSplitView.frame.height', +(classBrowser.frame.height + splitView.dividerThickness)) do
#           controller.toggleClassBrowser(nil)
#         end
#       #end
#     end
#   end
# end

describe 'ApplicationController, in general' do
  extend Controllers
  extend ApplicationControllerSpecHelper
  extend TemporaryApplicationSupportPath
  
  it "should update the `processing' state when the watcher finished indexing" do
    @controller.processing = 0
    
    @controller.startedIndexing(nil)
    @controller.valueForKey('processing').should == 1
    
    @controller.startedIndexing(nil)
    @controller.valueForKey('processing').should == 2
  end
  
  it "should update the `processing' state when the watcher finished indexing" do
    @controller.processing = 2
    
    @controller.finishedIndexing(nil)
    @controller.valueForKey('processing').should == 1
    
    @controller.finishedIndexing(nil)
    @controller.valueForKey('processing').should == 0
    
    @controller.finishedIndexing(nil)
    @controller.valueForKey('processing').should == 0
  end
  
  it "should update the `class_tree' when the watcher finished indexing" do
    @controller.processing = 1
    
    nodes = [mock('ClassTreeNode')]
    ClassTreeNode.expects(:classTreeNodesWithHashTree).with(@namespace_mock).returns(nodes)
    
    @controller.finishedIndexing(nil)
    @controller.class_tree.should == nodes
  end
  
  it "should keep the current selection in the class tree selected when updating the class tree" do
    @controller.processing = 1
    
    selection = mock('NSIndexPath')
    
    @classTreeController.expects(:selectionIndexPath).returns(selection)
    @classTreeController.expects(:setSelectionIndexPath).with(selection)
    
    @controller.finishedIndexing(nil)
  end
  
  it "should cleanup the Karidocs when the watcher finished indexing" do
    @controller.processing = 1
    Manager.expects(:cleanup)
    @controller.finishedIndexing(nil)
  end
  
  it "should set search_mode to `true' if a user started searching" do
    @controller.search_mode = false
    @controller.searchControllerWillStartSearching
    @controller.valueForKey('search_mode').should == true
  end
  
  # it "should set search_mode to `false' if a user selected a search result"  do
  #   controller.search_mode = true
  #   load_url!
  #   controller.valueForKey('search_mode').to_ruby.should.be false
  # end
  # 
  # it "should create a special search back forward item when a switching back to the webView" do
  #   load_url!
  #   webView.backForwardList.currentItem.URLString.should == 'kari://search/ActiveRecord'
  # end
  # 
  # it "should tell the webViewController to load a file if the searchController calls its selectedFile delegate method" do
  #   webViewController.expects(:load_url).with('/some/file.karidoc')
  #   load_url! '/some/file.karidoc'
  # end
  # 
  # it "should start a new search if a search back forward item was requested" do
  #   searchController.expects(:search).with(searchTextField)
  #   controller.webView_didSelectSearchQuery(nil, 'Binding')
  #   searchTextField.stringValue.should == 'Binding'
  # end
  # 
  # it "should always bring the webview to the front if the loaded page is bookmarkable" do
  #   webViewController.stubs(:bookmarkable?).returns(true)
  #   controller.search_mode = true
  #   controller.webViewFinishedLoading(nil)
  #   controller.valueForKey('search_mode').to_ruby.should.be false
  # end
  # 
  # it "should close all resources when terminating" do
  #   assigns(:watcher, @watcher_mock)
  #   
  #   @watcher_mock.expects(:stop)
  #   @manager_mock.expects(:close)
  #   controller.applicationWillTerminate(nil)
  # end
  # 
  # it "should rebuild the index when forced from the menu" do
  #   assigns(:watcher, @watcher_mock)
  #   @watcher_mock.expects(:forceRebuild)
  #   controller.rebuildIndex
  # end
end