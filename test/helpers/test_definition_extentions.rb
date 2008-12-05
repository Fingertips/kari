require File.expand_path('../../test_helper', __FILE__)

describe "An instance extended with DefinitionExtensions" do
  include DefinitionExtensions
  attr_accessor :full_name
  
  it "should return the proper separator" do
    self.full_name = 'Module'
    separator.should == '::'
    
    self.full_name = 'Module::SubModule'
    separator.should == '::'
    
    self.full_name = 'Module::SubModule#instancemethods'
    separator.should == '#'
    
    self.full_name = 'Module::SubModule.methods'
    separator.should == '.'
  end
  
  it "should return a path to itself" do
    self.full_name = 'Module'
    path.should == ''
    
    self.full_name = 'Module::SubModule'
    path.should == 'Module'
    
    self.full_name = 'Module::SubModule#instancemethods'
    path.should == 'Module::SubModule'
    
    self.full_name = 'Module::SubModule.methods'
    path.should == 'Module::SubModule'
  end
  
  it "should return the proper ri path" do
    self.class.stubs(:to_s).returns('RI::ClassDescription')
    ri_type.should == 'Class'
    
    self.class.stubs(:to_s).returns('RI::MethodDescription')
    ri_type.should == 'Method'
    
    self.class.stubs(:to_s).returns('Module')
    ri_type.should == 'Module'
  end
  
  it "should return the name of the template for a description" do
    self.stubs(:ri_type).returns('Class')
    template_name.should == 'class'
    self.stubs(:ri_type).returns('Module')
    template_name.should == 'module'
    self.stubs(:ri_type).returns('Method')
    template_name.should == 'method'
  end
  
  it "should type of the description" do
    self.class.stubs(:to_s).returns('RI::MethodDescription')
    @is_singleton = true
    type.should === 'ClassMethod'
    
    self.class.stubs(:to_s).returns('RI::MethodDescription')
    @is_singleton = false
    type.should === 'Method'
    
    self.class.stubs(:to_s).returns('RI::ClassDescription')
    type.should === 'Class'
  end
end