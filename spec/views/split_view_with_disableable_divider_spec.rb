require File.expand_path('../../spec_helper', __FILE__)

module SplitViewSpecHelper
  def self.extended(instance)
    instance.before do
      @split_view = SplitViewWithDisableableDivider.alloc.init
    end
  end
end

describe "SplitViewWithDisableableDivider, in general" do
  extend SplitViewSpecHelper
  
  [true, false].each do |bool|
    it "should reset the cursor rects when disableDivider set to #{bool}" do
      @split_view.expects(:resetCursorRects)
      @split_view.disableDivider = bool
    end
  end
end

describe "SplitViewWithDisableableDivider, when the divider is disabled" do
  extend SplitViewSpecHelper
  
  before do
    @split_view.disableDivider = true
  end
  
  it "should not do anything with mouseDown events" do
    @split_view.expects(:super_mouseDown).never
    @split_view.mouseDown(nil)
  end
  
  it "should not setup any cursor rects" do
    @split_view.expects(:super_resetCursorRects).never
    @split_view.resetCursorRects
  end
end

describe "SplitViewWithDisableableDivider, when the divider is enabled" do
  extend SplitViewSpecHelper
  
  before do
    @split_view.stubs(:super_resetCursorRects)
    @split_view.disableDivider = false
  end
  
  it "should process mouseDown events as normal" do
    event = mock('Mouse down event')
    @split_view.expects(:super_mouseDown).with(event)
    @split_view.mouseDown(event)
  end
  
  it "should setup cursor rects as normal" do
    @split_view.expects(:super_resetCursorRects)
    @split_view.resetCursorRects
  end
end