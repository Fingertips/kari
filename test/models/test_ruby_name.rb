require File.expand_path('../../test_helper', __FILE__)

describe "RubyName" do
  it "should split Ruby names to a path" do
    RubyName.split('').should == []
    RubyName.split('Module').should == ['Module']
    RubyName.split('Module::SubModule').should == ['Module', 'SubModule']
    RubyName.split('Module::Class.classmethod').should == ['Module', 'Class', 'classmethod']
    RubyName.split('Module::Class#instancemethod').should == ['Module', 'Class', 'instancemethod']
  end
  
  it "should convert RI filenames to Ruby names" do
    {
      '/Library/Ruby/Gems/1.8/doc/activerecord-2.0.2/ri/ActiveRecord/Associations/ClassMethods/has_one-i.yaml' => \
        'ActiveRecord::Associations::ClassMethods#has_one',
      '/Library/Ruby/Gems/1.8/doc/activerecord-2.0.2/ri/ActiveRecord/Associations/cdesc-Associations.yaml' => \
        'ActiveRecord::Associations',
      '/Library/Ruby/Gems/1.8/doc/activerecord-2.0.2/ri/ActiveRecord/Base/connected%3f-c.yaml' => \
        'ActiveRecord::Base::connected?',
      '/Library/Ruby/Gems/1.8/doc/activerecord-2.0.2/ri/ActiveRecord/Base/with_scope-c.yaml' => \
        'ActiveRecord::Base::with_scope'
    }.each do |filename, expected|
      RubyName.from_ri_filename(filename, '/Library/Ruby/Gems/1.8/doc/activerecord-2.0.2/ri').should == expected
    end
  end
  
  # FIXME: At the moment we make no disctintion between a class and instance method.
  it "should convert Karidoc filenames to Ruby names" do
    {
      '/Users/eloy/Library/Application Support/Kari/Karidoc/ActiveRecord/Associations/ClassMethods/has_one.karidoc' => \
        'ActiveRecord::Associations::ClassMethods::has_one',
      '/Users/eloy/Library/Application Support/Kari/Karidoc/ActiveRecord/Associations.karidoc' => \
        'ActiveRecord::Associations',
      '/Users/eloy/Library/Application Support/Kari/Karidoc/ActiveRecord/Base/connected?.karidoc' => \
        'ActiveRecord::Base::connected?'
    }.each do |filename, expected|
      RubyName.from_karidoc_filename(filename).should == expected
    end
  end
end