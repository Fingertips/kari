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
    description_file = file_fixture('ri', 'Binding', 'cdesc-Binding.yaml')
    KaridocGenerator.generate(description_file)
    File.should.exist(KaridocGenerator.filename('Binding'))
  end
  
  it "should generate a documentation file for a ri method description" do
    description_file = file_fixture('ri', 'Binding', 'clone-i.yaml')
    KaridocGenerator.generate(description_file)
    File.should.exist(KaridocGenerator.filename('Binding#clone'))
  end
  
  it "should memoize ERB templates" do
    template_file = File.join(File.expand_path('../../../app/views/karidoc', __FILE__), 'layout.erb')
    ERB.expects(:new).returns('').times(1)
    KaridocGenerator.template(template_file)
    KaridocGenerator.template(template_file)
  end
end

describe "A KaridocGenerator" do
  include TemporaryApplicationSupportPath
  include FixtureHelpers
  
  before do
    @generator = KaridocGenerator.new([
      file_fixture('ri', 'Binding', 'cdesc-Binding.yaml'),
      file_fixture('alternate-ri', 'Binding', 'cdesc-Binding.yaml')
    ])
  end
  
  it "should generate" do
    filename = @generator.generate
    filename.should == KaridocGenerator.filename('Binding')
    File.read(filename).should =~ /<title>Binding<\/title>/
  end
  
  it "should render ri definitions" do
    result = @generator.render([YAML::load_file(@generator.definition_files.first)])
    result.should =~ /<title>Binding<\/title>/
  end
end

describe "A KaridocGenerator, rendering karidoc" do
  include TemporaryApplicationSupportPath
  include FixtureHelpers
  
  it "should render a class" do
    KaridocGenerator.generate([file_fixture('ri', 'Binding', 'cdesc-Binding.yaml')])
    File.read(KaridocGenerator.filename('Binding')).should =~ /<title>Binding<\/title>/
  end
  
  it "should render a class method" do
    KaridocGenerator.generate([file_fixture('ri', 'Mutex', 'new-c.yaml')])
    File.read(KaridocGenerator.filename('Mutex.new')).should =~ /<title>Mutex::new<\/title>/
  end
  
  it "should render an instance method" do
    KaridocGenerator.generate([file_fixture('ri', 'Mutex', 'lock-i.yaml')])
    File.read(KaridocGenerator.filename('Mutex#lock')).should =~ /<title>Mutex#lock<\/title>/
  end
end