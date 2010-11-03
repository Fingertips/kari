require File.expand_path('../../spec_helper', __FILE__)

describe "OrderedWebHistory" do
  before do
    @history = OrderedWebHistory.alloc.init
  end
  
  it "returns the last calendar date for its items" do
    @history.expects(:orderedLastVisitedDays).returns([2, 1, 0])
    @history.expects(:orderedItemsLastVisitedOnDay).with(2).returns([:last, :first])
    @history.last.should == :last
  end
end