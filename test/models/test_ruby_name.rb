require File.expand_path('../../test_helper', __FILE__)

describe "RubyName" do
  it "should split Ruby names to a path" do
    RubyName.split('').should == []
    RubyName.split('Module').should == ['Module']
    RubyName.split('Module::SubModule').should == ['Module', 'SubModule']
    RubyName.split('Module::Class.classmethod').should == ['Module', 'Class', 'classmethod']
    RubyName.split('Module::Class#instancemethod').should == ['Module', 'Class', 'instancemethod']
  end
end