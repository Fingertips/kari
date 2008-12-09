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
    KaridocGenerator.filename('Module').should.start_with(KaridocGenerator.filepath)
    KaridocGenerator.filename('Module').should.end_with(KaridocGenerator::EXTENSION)
    
    KaridocGenerator.filename('Module::SubModule').should.include('Module/SubModule')
    KaridocGenerator.filename('Module::SubModule.method').should.include('Module/SubModule/method')
  end
  
  it "should generate a documentation file for a ri class description" do
    description_file = file_fixture('normal', 'ri', 'Binding', 'cdesc-Binding.yaml')
    KaridocGenerator.generate(description_file)
    File.should.exist(KaridocGenerator.filename('Binding'))
  end
  
  it "should generate a documentation file for a ri method description" do
    description_file = file_fixture('normal', 'ri', 'Binding', 'clone-i.yaml')
    KaridocGenerator.generate(description_file)
    File.should.exist(KaridocGenerator.filename('Binding#clone'))
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
    File.should.exist?(KaridocGenerator.filename(full_name))
    KaridocGenerator.clear(full_name)
    File.should.not.exist?(KaridocGenerator.filename(full_name))
  end
  
  it "should clear documentation directories when they're empty" do
    names = ['Binding#clone', 'Binding#dup']
    File.should.exist?(File.dirname(KaridocGenerator.filename(names.first)))
    names.each { |full_name| KaridocGenerator.clear(full_name) }
    File.should.not.exist?(File.dirname(KaridocGenerator.filename(names.first)))
  end
  
  it "should silently ignore clearing missing documentation directories" do
    names = ['Binding#clone']*3
    lambda {
      names.each { |full_name| KaridocGenerator.clear(full_name) }
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
    filename.should == KaridocGenerator.filename('Binding')
    File.read(filename).should =~ /<title>Binding<\/title>/
  end
  
  it "should render ri descriptions" do
    result = @generator.render([YAML::load_file(@generator.description_files.first)])
    result.should =~ /<title>Binding<\/title>/
  end
end

describe "A KaridocGenerator, rendering karidoc" do
  include TemporaryApplicationSupportPath
  include FixtureHelpers
  
  it "should render a class" do
    KaridocGenerator.generate([file_fixture('normal', 'ri', 'Binding', 'cdesc-Binding.yaml')])
    File.read(KaridocGenerator.filename('Binding')).should =~ /<title>Binding<\/title>/
  end
  
  it "should render a class method" do
    KaridocGenerator.generate([file_fixture('normal', 'ri', 'Mutex', 'new-c.yaml')])
    File.read(KaridocGenerator.filename('Mutex.new')).should =~ /<title>Mutex::new<\/title>/
  end
  
  it "should render an instance method" do
    KaridocGenerator.generate([file_fixture('normal', 'ri', 'Mutex', 'lock-i.yaml')])
    File.read(KaridocGenerator.filename('Mutex#lock')).should =~ /<title>Mutex#lock<\/title>/
  end
end