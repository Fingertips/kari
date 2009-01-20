require File.expand_path('../../test_helper', __FILE__)

describe "RubyName" do
  CASES = [
    {
      :path                 => ['Mutex', '#exclusive_unlock'],
      :ruby_name            => 'Mutex#exclusive_unlock',
      :description_filename => '/Library/Ruby/Gems/1.8/doc/activerecord-2.0.2/ri/Mutex/exclusive_unlock-i.yaml',
      :karidoc_filename     => '/Users/eloy/Library/Application Support/Kari/Karidoc.5231.0/Mutex/#exclusive_unlock.karidoc',
      :karidoc_path         => '/Mutex/#exclusive_unlock.karidoc'
    },
    {
      :path                 => ['ActiveRecord'],
      :ruby_name            => 'ActiveRecord',
      :description_filename => '/Library/Ruby/Gems/1.8/doc/activerecord-2.0.2/ri/ActiveRecord/cdesc-ActiveRecord.yaml',
      :karidoc_filename     => '/Users/eloy/Library/Application Support/Kari/Karidoc.5231.0/ActiveRecord.karidoc',
      :karidoc_path         => '/ActiveRecord.karidoc'
    },
    {
      :path                 => ['ActiveRecord', 'Associations', 'ClassMethods', '#has_one'],
      :ruby_name            => 'ActiveRecord::Associations::ClassMethods#has_one',
      :description_filename => '/Library/Ruby/Gems/1.8/doc/activerecord-2.0.2/ri/ActiveRecord/Associations/ClassMethods/has_one-i.yaml',
      :karidoc_filename     => '/Users/eloy/Library/Application Support/Kari/Karidoc.5231.0/ActiveRecord/Associations/ClassMethods/#has_one.karidoc',
      :karidoc_path         => '/ActiveRecord/Associations/ClassMethods/#has_one.karidoc'
    },
    {
      :path                 => ['ActiveRecord', 'Associations'],
      :ruby_name            => 'ActiveRecord::Associations',
      :description_filename => '/Library/Ruby/Gems/1.8/doc/activerecord-2.0.2/ri/ActiveRecord/Associations/cdesc-Associations.yaml',
      :karidoc_filename     => '/Users/eloy/Library/Application Support/Kari/Karidoc.5231.0/ActiveRecord/Associations.karidoc',
      :karidoc_path         => '/ActiveRecord/Associations.karidoc'
    },
    {
      :path                 => ['ActiveRecord', 'Base', 'connected?'],
      :ruby_name            => 'ActiveRecord::Base::connected?',
      :description_filename => '/Library/Ruby/Gems/1.8/doc/activerecord-2.0.2/ri/ActiveRecord/Base/connected%3f-c.yaml',
      :karidoc_filename     => '/Users/eloy/Library/Application Support/Kari/Karidoc.5231.0/ActiveRecord/Base/connected?.karidoc',
      :karidoc_path         => '/ActiveRecord/Base/connected?.karidoc'
    },
    {
      :path                 => ['ActiveRecord', 'Base', 'with_scope'],
      :ruby_name            => 'ActiveRecord::Base::with_scope',
      :description_filename => '/Library/Ruby/Gems/1.8/doc/activerecord-2.0.2/ri/ActiveRecord/Base/with_scope-c.yaml',
      :karidoc_filename     => '/Users/eloy/Library/Application Support/Kari/Karidoc.5231.0/ActiveRecord/Base/with_scope.karidoc',
      :karidoc_path         => '/ActiveRecord/Base/with_scope.karidoc'
    },
    {
      :path                 => ['ActiveRecord', 'Base', '#readonly!'],
      :ruby_name            => 'ActiveRecord::Base#readonly!',
      :description_filename => '/Library/Ruby/Gems/1.8/doc/activerecord-2.0.2/ri/ActiveRecord/Base/readonly%21-i.yaml',
      :karidoc_filename     => '/Users/eloy/Library/Application Support/Kari/Karidoc.5231.0/ActiveRecord/Base/#readonly!.karidoc',
      :karidoc_path         => '/ActiveRecord/Base/#readonly!.karidoc'
    }
  ]
  
  before do
    Rucola::RCApp.stubs(:application_support_path).returns('/Users/eloy/Library/Application Support/Kari')
  end
  
  it "should split Ruby names to a path" do
    RubyName.split('').should == []
    RubyName.split('REST.perform').should == ['REST', 'perform']
    CASES.each do |c|
      RubyName.split(c[:ruby_name]).should == c[:path]
    end
  end
  
  it "should convert RI filenames to Ruby names" do
    CASES.each do |c|
      RubyName.from_ri_filename(c[:description_filename], '/Library/Ruby/Gems/1.8/doc/activerecord-2.0.2/ri').should == c[:ruby_name]
    end
  end
  
  it "should convert Karidoc filenames to Ruby names" do
    CASES.each do |c|
      RubyName.from_karidoc_filename('/Users/eloy/Library/Application Support/Kari/Karidoc.5231.0', c[:karidoc_filename]).should == c[:ruby_name]
    end
  end
  
  it "should convert Karidoc paths to Ruby name" do
    CASES.each do |c|
      RubyName.from_karidoc_path(c[:karidoc_path]).should == c[:ruby_name]
    end
  end
  
  it "should convert Ruby names to a Karidoc path" do
    CASES.each do |c|
      RubyName.karidoc_filename('/Users/eloy/Library/Application Support/Kari/Karidoc.5231.0', c[:ruby_name]).should == c[:karidoc_filename]
    end
  end
  
  it "should convert Ruby names to a relative Karidoc path" do
    CASES.each do |c|
      RubyName.relative_karidoc_path(c[:ruby_name]).should == c[:karidoc_path].split(File::SEPARATOR)[1..-1].join(File::SEPARATOR)
    end
  end
end