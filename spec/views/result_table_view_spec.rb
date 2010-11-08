require File.expand_path('../../spec_helper', __FILE__)

describe "ResultsTableView" do
  before do
    @table_view = ResultsTableView.alloc.init
  end
  
  it "scrolls when receiving a key" do
    @table_view.expects(:scrollToRow).with(0)
    @table_view.control(mock('Control'), textView:mock('Search View'), doCommandBySelector:'moveDown:')
  end
end