require File.expand_path('../../test_helper', __FILE__)

describe "Namespace" do
  it "should split names to a path" do
    Namespace.split('').should == []
    Namespace.split('Module').should == ['Module']
    Namespace.split('Module::SubModule').should == ['Module', 'SubModule']
    Namespace.split('Module::Class.classmethod').should == ['Module', 'Class', 'classmethod']
    Namespace.split('Module::Class#instancemethod').should == ['Module', 'Class', 'instancemethod']
  end
end