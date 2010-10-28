require File.expand_path('../../spec_helper', __FILE__)

describe "NilClass" do
  it "should always return true for blank" do
    nil.should.be.blank
  end
end