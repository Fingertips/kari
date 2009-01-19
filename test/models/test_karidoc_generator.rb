#!/usr/bin/env macruby

require File.expand_path('../../test_helper', __FILE__)

describe "KaridocGenerator" do
  include TemporaryApplicationSupportPath
  include FixtureHelpers
  
  after do
    KaridocGenerator.class_eval { @template = nil }
  end
  
  it "should generate a documentation file for a ri class description" do
    description_file = file_fixture('normal', 'ri', 'Binding', 'cdesc-Binding.yaml')
    filename = KaridocGenerator.generate(description_file)
    File.should.exist(filename)
  end
  
  it "should generate a documentation file for a ri instance method description" do
    description_file = file_fixture('normal', 'ri', 'Binding', 'clone-i.yaml')
    filename = KaridocGenerator.generate(description_file)
    File.should.exist(filename)
  end
  
  it "should generate a documentation file for a ri class method description" do
    description_file = file_fixture('normal', 'ri', 'Mutex', 'new-c.yaml')
    filename = KaridocGenerator.generate(description_file)
    File.should.exist(filename)
  end
  
  it "should memoize ERB templates" do
    template_file = File.join(File.expand_path('../../../app/views/karidoc', __FILE__), 'layout.erb')
    KaridocGenerator.template(template_file)
    KaridocGenerator.instance_variable_get(:@template)[template_file].should.not.be nil
  end
  
  it "should recursively delete empty directories" do
    base_path = File.join(Dir.tmpdir, 'base-path')
    very_long_empty_path = File.join(base_path, 'very', 'long', 'directory', 'with', 'a', 'lot', 'of', 'names')
    FileUtils.mkdir_p(very_long_empty_path)
    File.open(File.join(base_path, 'a-file'), 'w') { |fp| fp.write('Contents') }
    
    KaridocGenerator.clear_if_empty(very_long_empty_path)
    File.should.exist(base_path)
    File.should.not.exist(very_long_empty_path)
  end
end

describe "KaridocGenerator, on a generated karidoc tree" do
  include TemporaryApplicationSupportPath
  include FixtureHelpers
  
  before do
    @manager = Manager.new
    @manager.examine(File.join(TEST_ROOT, 'fixtures', 'normal', 'ri'))
  end
  
  after do
    @manager.close
  end
  
  it "should clear documentation files for a description" do
    full_name = 'Binding'
    File.should.exist?(RubyName.karidoc_filename(full_name))
    KaridocGenerator.clear(full_name)
    File.should.not.exist?(RubyName.karidoc_filename(full_name))
  end
  
  it "should clear documentation directories when they're empty" do
    names = ['Binding#clone', 'Binding#dup']
    File.should.exist?(File.dirname(RubyName.karidoc_filename(names.first)))
    names.each { |full_name, description_filename| KaridocGenerator.clear(full_name) }
    File.should.not.exist?(File.dirname(RubyName.karidoc_filename(names.first)))
  end
  
  it "should silently ignore clearing missing documentation directories" do
    names = ['Binding#clone']*3
    lambda {
      names.each { |full_name, description_filename| KaridocGenerator.clear(full_name) }
    }.should.not.raise
  end
end

describe "A KaridocGenerator" do
  include TemporaryApplicationSupportPath
  include FixtureHelpers
  
  before do
    @generator = KaridocGenerator.new([
      file_fixture('normal', 'ri', 'Binding', 'cdesc-Binding.yaml'),
      file_fixture('alternate', 'ri', 'Binding', 'cdesc-Binding.yaml')
    ])
  end
  
  it "should generate" do
    filename = @generator.generate
    filename.should == RubyName.karidoc_filename('Binding')
    File.read(filename).should =~ /<title>Binding<\/title>/
  end
  
  it "should render ri descriptions" do
    result = @generator.render([YAML::load_file(@generator.description_files.first)])
    result.should =~ /<title>Binding<\/title>/
  end
end