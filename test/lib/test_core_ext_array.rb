#!/usr/bin/env macruby

require File.expand_path('../../test_helper', __FILE__)

describe "Array" do
  it "should be blank when it's empty" do
    [].should.be.blank
    ['1'].should.not.be.blank
  end
end