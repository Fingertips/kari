require File.expand_path('../../test_helper', __FILE__)

module FixtureHelpers
  def file_fixture(*parts)
    File.join(TEST_ROOT, 'fixtures', *parts)
  end
end

describe "Generator" do
  include TemporaryApplicationSupportPath
  include FixtureHelpers
  
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
    File.read(Generator.filename('Binding')).should =~ /Binding/
  end
end