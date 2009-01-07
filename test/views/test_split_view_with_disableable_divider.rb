#!/usr/bin/env macruby

require File.expand_path('../../test_helper', __FILE__)

module SplitViewSpecHelper
  def self.included(klass)
    klass.class_eval do
      tests SplitViewWithDisableableDivider
      alias_method :split_view, :instance_to_be_tested
    end
  end
end

describe "SplitViewWithDisableableDivider, in general" do
  include SplitViewSpecHelper
  
  [true, false].each do |bool|
    it "should reset the cursor rects when disableDivider set to #{bool}" do
      split_view.expects(:resetCursorRects)
      split_view.disableDivider = bool
    end
  end
end

describe "SplitViewWithDisableableDivider, when the divider is disabled" do
  include SplitViewSpecHelper
  
  def after_setup
    split_view.disableDivider = true
  end
  
  it "should not do anything with mouseDown events" do
    split_view.expects(:super_mouseDown).never
    split_view.mouseDown(nil)
  end
  
  it "should not setup any cursor rects" do
    split_view.expects(:super_resetCursorRects).never
    split_view.resetCursorRects
  end
end

describe "SplitViewWithDisableableDivider, when the divider is enabled" do
  include SplitViewSpecHelper
  
  def after_setup
    split_view.stubs(:super_resetCursorRects)
    split_view.disableDivider = false
  end
  
  it "should process mouseDown events as normal" do
    event = mock('Mouse down event')
    split_view.expects(:super_mouseDown).with(event)
    split_view.mouseDown(event)
  end
  
  it "should setup cursor rects as normal" do
    split_view.expects(:super_resetCursorRects)
    split_view.resetCursorRects
  end
end