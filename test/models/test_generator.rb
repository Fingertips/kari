require File.expand_path('../../test_helper', __FILE__)

describe "Generator" do
  before do
    @application_support_path = File.join(Dir.tmpdir, 'kari-application-support-path')
    Rucola::RCApp.stubs(:application_support_path).returns(@application_support_path)
  end
  
  after do
    FileUtils.rm_rf(@application_support_path)
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
    description_file = ri_fixture('Binding', 'cdesc-Binding.yaml')
    Generator.generate(description_file)
    File.should.exist(Generator.filename('Binding'))
  end
  
  def ri_fixture(*parts)
    File.join(TEST_ROOT, 'fixtures', 'ri', *parts)
  end
end