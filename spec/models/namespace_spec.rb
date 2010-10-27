require File.expand_path('../../spec_helper', __FILE__)

describe "A Namespace" do
  before do
    @namespace = Namespace.new('full_name' => 'Object')
  end
  
  it "should know what it responds to" do
    @namespace.respond_to?(:full_name).should == true
    @namespace.respond_to?(:binding).should == true
    @namespace.respond_to?(:respond_to?).should == true
    @namespace.respond_to?(:unknown).should == false
  end
  
  it "should respond to namespace keys" do
    @namespace.full_name.should == 'Object'
  end
  
  it "should throw an exception on unknown keys" do
    lambda {
      @namespace.unknown
    }.should.raise(NoMethodError)
  end
  
  it "should be able to assign new keys to the namespace" do
    @namespace.respond_to?(:name).should == false
    @namespace.assign('name', '…')
    @namespace.respond_to?(:name).should == true
  end
  
  it "should have a public binding" do
    lambda {
      @namespace.binding
    }.should.not.raise
  end
end