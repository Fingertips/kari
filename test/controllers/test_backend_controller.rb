require File.expand_path('../../test_helper', __FILE__)

describe 'BackendController' do
  before do
    @controller = BackendController.alloc.init
  end

  it "should initialize" do
    @controller.should.be.an.instance_of BackendController
  end
  
  it "should do stuff at awakeFromNib" do
    # Some example code of testing your #awakeFromNib.
    #
    # @controller.ib_outlet(:some_text_view).expects(:string=).with('foo')
    
    # @controller.awakeFromNib
  end
end