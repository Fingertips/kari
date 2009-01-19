require File.expand_path('../../test_helper', __FILE__)

describe "NilClass" do
  it "should always return true for blank" do
    nil.should.be.blank
  end
  
  it "should return nil if coercing to_ruby" do
    nil.to_ruby.should.be nil
  end
end