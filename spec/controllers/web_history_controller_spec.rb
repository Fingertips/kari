require File.expand_path('../../spec_helper', __FILE__)

describe 'WebHistoryController' do
  extend TemporaryApplicationSupportPath
  
  it "should create the Kari app support dir if it doesn't exist yet" do
    application_support_path = Kari.application_support_path
    
    File.should.not.exist?(application_support_path)
    WebHistoryController.alloc.init
    File.should.exist?(application_support_path)
  end
end