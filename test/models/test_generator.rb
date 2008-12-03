require File.expand_path('../../test_helper', __FILE__)

module FixtureHelpers
  def file_fixture(*parts)
    File.join(TEST_ROOT, 'fixtures', *parts)
  end
end

describe "Generator" do
  include TemporaryApplicationSupportPath
  include FixtureHelpers
  
  after do
    Generator.class_eval { @template = nil }
  end
  
  it "should return the filepath" do
    Generator.filepath.should.start_with(@application_support_path)
    Generator.filepath.should.end_with('Karidoc')
  end
  
  it "should generate a filename from a Ruby name" do
    Generator.filename('Module').should.start_with(Generator.filepath)
    Generator.filename('Module').should.end_with(Generator::EXTENSION)
    
    Generator.filename('Module::SubModule').should.include('Module/SubModule')
    Generator.filename('Module::SubModule.method').should.include('Module/SubModule/method')
  end
  
  it "should generate a documentation file for a ri class description" do
    description_file = file_fixture('ri', 'Binding', 'cdesc-Binding.yaml')
    Generator.generate(description_file)
    File.should.exist(Generator.filename('Binding'))
  end
  
  it "should generate a documentation file for a ri method description" do
    description_file = file_fixture('ri', 'Binding', 'clone-i.yaml')
    Generator.generate(description_file)
    File.should.exist(Generator.filename('Binding#clone'))
  end
  
  it "should memoize ERB templates" do
    template_file = File.join(File.expand_path('../../../app/views/karidoc', __FILE__), 'layout.erb')
    ERB.expects(:new).returns('').times(1)
    Generator.template(template_file)
    Generator.template(template_file)
  end
end

describe "A Generator" do
  include TemporaryApplicationSupportPath
  include FixtureHelpers
  
  before do
    @generator = Generator.new([
      file_fixture('ri', 'Binding', 'cdesc-Binding.yaml'),
      file_fixture('alternate-ri', 'Binding', 'cdesc-Binding.yaml')
    ])
  end
  
  it "should generate" do
    @generator.generate
    File.read(Generator.filename('Binding')).should =~ /<title>Binding<\/title>/
  end
  
  it "should render ri definitions" do
    result = @generator.render([YAML::load_file(@generator.definition_files.first)])
    result.should =~ /<title>Binding<\/title>/
  end
end

describe "A Generator, rendering karidoc" do
  include TemporaryApplicationSupportPath
  include FixtureHelpers
  
  it "should render a class" do
    Generator.generate([file_fixture('ri', 'Binding', 'cdesc-Binding.yaml')])
    File.read(Generator.filename('Binding')).should =~ /<title>Binding<\/title>/
  end
  
  it "should render a class method" do
    Generator.generate([file_fixture('ri', 'Mutex', 'new-c.yaml')])
    File.read(Generator.filename('Mutex.new')).should =~ /<title>Mutex::new<\/title>/
  end
  
  it "should render an instance method" do
    Generator.generate([file_fixture('ri', 'Mutex', 'lock-i.yaml')])
    File.read(Generator.filename('Mutex#lock')).should =~ /<title>Mutex#lock<\/title>/
  end
end