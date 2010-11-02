require File.expand_path('../../spec_helper', __FILE__)

describe "ToolbarController" do
  extend Controllers
  
  before do
    @controller = ToolbarController.alloc.init
    
    stub_outlets(@controller,
      :window                    => NSWindow.alloc.init,
      :historyBackAndForwardView => mock('History View'),
      :searchView                => mock('Search View'),
      :toggleClassBrowserView    => mock('Class Browser View')
    )
  end
  
  it "should setup a NSToolbar instance" do
    show_backtrace do
      @controller.instance_variable_get('@toolbar').should.be.kind_of(NSToolbar)
    end
  end
end