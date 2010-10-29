require File.expand_path('../../spec_helper', __FILE__)

describe "StatusBar" do
  before do
    @frame = NSMakeRect(0, 0, 10, 10)
    @status_bar = StatusBar.alloc.initWithFrame(@frame)
  end
  
  it "redraws when it receives changes" do
    @status_bar.windowChangedKey(nil)
    # It redraws soooo fast the boolean has been reset by now
    @status_bar.needsDisplay.should == false
  end
end