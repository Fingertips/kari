require File.expand_path('../../spec_helper', __FILE__)

describe "String" do
  it "should know if it's blank" do
    ''.should.be.blank
    ' '.should.not.be.blank
    'Not'.should.not.be.blank
  end
end