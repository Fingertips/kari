require File.expand_path('../../test_helper', __FILE__)

describe "A Namespace" do
  before do
    @namespace = Namespace.new 'full_name' => 'Object'
  end
  
  it "should know what it responds to" do
    @namespace.should.respond_to?(:full_name)
    @namespace.should.respond_to?(:binding)
    @namespace.should.respond_to?(:respond_to?)
    @namespace.should.not.respond_to?(:unknown)
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
    @namespace.should.not.respond_to?(:description)
    @namespace.assign('description', '…')
    @namespace.should.respond_to?(:description)
  end
  
  it "should have a public binding" do
    lambda {
      @namespace.binding
    }.should.not.raise
  end
end