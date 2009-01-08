#!/usr/bin/env macruby

require File.expand_path('../../test_helper', __FILE__)

describe "String" do
  it "should know if it starts with a certain prefix" do
    str = 'My movie'
    str.should.start_with('M')
    str.should.start_with('My')
    str.should.not.start_with('y')
    str.should.not.start_with('ie')
  end
  
  it "should know if it ends with a certain suffix" do
    str = 'My movie'
    str.should.end_with('ie')
    str.should.end_with('e')
    str.should.not.end_with('M')
    str.should.not.end_with('My')
  end
  
  it "should know if it's blank" do
    str = ''
    str.should.be.blank
    (str << ' ').should.not.be.blank
    (str << 'Not').should.not.be.blank
  end
end