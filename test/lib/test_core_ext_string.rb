require File.expand_path('../../test_helper', __FILE__)

describe "String" do
  it "should know if it starts with a certain prefix" do
    'My movie'.should.start_with('M')
    'My movie'.should.start_with('My')
    'My movie'.should.not.start_with('y')
    'My movie'.should.not.start_with('ie')
  end
  
  it "should know if it ends with a certain suffix" do
    'My movie'.should.end_with('ie')
    'My movie'.should.end_with('e')
    'My movie'.should.not.end_with('M')
    'My movie'.should.not.end_with('My')
  end
end