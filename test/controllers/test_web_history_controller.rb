require File.expand_path('../../test_helper', __FILE__)

describe 'WebHistoryController' do
  # before do
  #   @controller = WebHistoryController.alloc.init
  # end
  
  it "should create the Kari app support dir if it doesn't exist yet" do
    dir = File.expand_path('~/Library/Application Support/Kari')
    File.expects(:exist?).with(dir).returns(false)
    FileUtils.expects(:mkdir_p).with(dir)
    
    WebHistoryController.alloc.init
  end
end