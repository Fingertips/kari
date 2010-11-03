require File.expand_path('../../spec_helper', __FILE__)

module WebHistoryControllerSpecHelper
  def self.extended(klass)
    klass.before do
      @controller = WebHistoryController.alloc.init
      stub_outlets(@controller,
        :historyMenu => NSMenu.alloc.init,
        :webViewController => WebViewController.alloc.init
      )
    end
  end
end

describe "WebHistoryController" do
  extend TemporaryApplicationSupportPath
  
  it "should create the Kari app support dir if it doesn't exist yet" do
    application_support_path = Kari.application_support_path
    
    File.should.not.exist?(application_support_path)
    WebHistoryController.alloc.init
    File.should.exist?(application_support_path)
  end
end

describe "WebHistoryController, when awaking from nib" do
  extend Controllers
  extend WebHistoryControllerSpecHelper
  
  it "loads the history from the predefined path" do
    @controller.awakeFromNib
    @controller.instance_variable_get('@history').orderedLastVisitedDays.should.be.empty
  end
end