require File.expand_path('../../test_helper', __FILE__)

describe "ResultsTableView" do
  tests ResultsTableView
  alias_method :table_view, :instance_to_be_tested
  
  def after_setup
    @clip_view = stub('Clip View')
    @scroll_view = stub('Scroll View')
    table_view.stubs(:superview).returns(@clip_view)
    @clip_view.stubs(:superview).returns(@scroll_view)
  end
  
  it "should only want to have key events forwarded if the superview is not hidden" do
    @scroll_view.stubs(:hidden?).returns(false)
    table_view.should.wantsForwardedKeyEvents
  end
  
  it "should not want to have key events forwarded if the superview is hidden" do
    @scroll_view.stubs(:hidden?).returns(true)
    table_view.should.not.wantsForwardedKeyEvents
  end
end