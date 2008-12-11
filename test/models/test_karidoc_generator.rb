require File.expand_path('../../test_helper', __FILE__)

describe "KaridocGenerator" do
  include TemporaryApplicationSupportPath
  include FixtureHelpers
  
  after do
    KaridocGenerator.class_eval { @template = nil }
  end
  
  it "should return the filepath" do
    KaridocGenerator.filepath.should.start_with(@application_support_path)
    KaridocGenerator.filepath.should.end_with('Karidoc')
  end
  
  it "should generate a filename from a Ruby name" do
    KaridocGenerator.filename('Module', '/path/to/cdesc-Module.yaml').should.start_with(KaridocGenerator.filepath)
    KaridocGenerator.filename('Module', '/path/to/cdesc-Module.yaml').should.end_with(KaridocGenerator::EXTENSION)
    
    KaridocGenerator.filename('Module::SubModule', '/path/to/Module/cdesc-SubModule.yaml').should.include('Module/SubModule')
    KaridocGenerator.filename('Module::SubModule.method', '/path/to/Module/SubModule/method-c.yaml').should.include('Module/SubModule/class-method-method')
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
    ERB.expects(:new).returns('').times(1)
    KaridocGenerator.template(template_file)
    KaridocGenerator.template(template_file)
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
    File.should.exist?(KaridocGenerator.filename(full_name, file_fixture('normal', 'ri', 'cdesc-Binding.yaml')))
    KaridocGenerator.clear(full_name, file_fixture('normal', 'ri', 'cdesc-Binding.yaml'))
    File.should.not.exist?(KaridocGenerator.filename(full_name, file_fixture('normal', 'ri', 'cdesc-Binding.yaml')))
  end
  
  it "should clear documentation directories when they're empty" do
    names = [
      ['Binding#clone', file_fixture('normal', 'ri', 'Binding', 'clone-i.yaml')],
      ['Binding#dup', file_fixture('normal', 'ri', 'Binding', 'dup-i.yaml')]
    ]
    File.should.exist?(File.dirname(KaridocGenerator.filename(*names.first)))
    names.each { |full_name, description_filename| KaridocGenerator.clear(full_name, description_filename) }
    File.should.not.exist?(File.dirname(KaridocGenerator.filename(*names.first)))
  end
  
  it "should silently ignore clearing missing documentation directories" do
    names = [['Binding#clone', file_fixture('normal', 'ri', 'Binding', 'clone-i.yaml')]]*3
    lambda {
      names.each { |full_name, description_filename| KaridocGenerator.clear(full_name, description_filename) }
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
    filename.should == KaridocGenerator.filename('Binding', file_fixture('normal', 'ri', 'Binding', 'cdesc-Binding.yaml'))
    File.read(filename).should =~ /<title>Binding<\/title>/
  end
  
  it "should render ri descriptions" do
    result = @generator.render([YAML::load_file(@generator.description_files.first)])
    result.should =~ /<title>Binding<\/title>/
  end
end