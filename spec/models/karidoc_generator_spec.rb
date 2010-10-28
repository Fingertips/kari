require File.expand_path('../../spec_helper', __FILE__)

describe "KaridocGenerator" do
  extend TemporaryApplicationSupportPath
  extend FixtureHelpers
  
  before do
    @karidoc_path = File.join(Kari.application_support_path, 'Karidoc.6345.1')
  end
  
  after do
    KaridocGenerator.class_eval { @template = nil }
  end
  
  it "should generate a documentation file for a ri class description" do
    description_file = file_fixture('normal', 'ri', 'Binding', 'cdesc-Binding.yaml')
    filename = KaridocGenerator.generate(@karidoc_path, description_file)
    File.should.exist(File.join(@karidoc_path, filename))
  end
  
  it "should generate a documentation file for a ri instance method description" do
    description_file = file_fixture('normal', 'ri', 'Binding', 'clone-i.yaml')
    filename = KaridocGenerator.generate(@karidoc_path, description_file)
    File.should.exist(File.join(@karidoc_path, filename))
  end
  
  it "should generate a documentation file for a ri class method description" do
    description_file = file_fixture('normal', 'ri', 'Mutex', 'new-c.yaml')
    filename = KaridocGenerator.generate(@karidoc_path, description_file)
    File.should.exist(File.join(@karidoc_path, filename))
  end
  
  it "should memoize ERB templates" do
    template_file = File.expand_path('../../../app/views/karidoc/layout.erb', __FILE__)
    # DISABLED because stubbing classmethods is currently broken in Mocha (http://www.macruby.org/trac/ticket/982)
    # ERB.expects(:new).returns('').times(1)
    KaridocGenerator.template(template_file)
    KaridocGenerator.template(template_file)
    KaridocGenerator.class_eval { @template }.keys.should.include(template_file)
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
  
  it "should compute relative path from root" do
    KaridocGenerator.compute_relative_path_from_root('/path/to', '/path/to/file').should == '/file'
  end
  
  it "should compute relative path to root" do
    KaridocGenerator.compute_relative_path_to_root('/path').should == ''
    KaridocGenerator.compute_relative_path_to_root('/path/to').should == '..'
    KaridocGenerator.compute_relative_path_to_root('/path/to/file').should == '../..'
  end
  
  # DISABLED because stubbing classmethods is currently broken in Mocha (http://www.macruby.org/trac/ticket/982)
  # it "should freeze assets" do
  #   generator = stub
  #   generator.expects(:freeze_assets)
  #   KaridocGenerator.expects(:new).with(@karidoc_path).returns(generator)
  #   
  #   KaridocGenerator.freeze_assets(@karidoc_path)
  # end
end

describe "KaridocGenerator, on a generated karidoc tree" do
  extend TemporaryApplicationSupportPath
  extend FixtureHelpers
  
  before do
    @manager = Manager.new
    @manager.examine(File.join(TEST_ROOT_PATH, 'fixtures', 'normal', 'ri'))
  end
  
  after do
    @manager.close
  end
  
  it "should clear documentation files for a description" do
    full_name = 'Binding'
    filename = RubyName.karidoc_filename(@manager.filepath, full_name)
    
    File.should.exist?(filename)
    KaridocGenerator.clear(@manager.filepath, full_name)
    File.should.not.exist(filename)
  end
  
  it "should clear documentation directories when they're empty" do
    names = ['Binding#clone', 'Binding#dup']
    dirname = File.dirname(RubyName.karidoc_filename(@manager.filepath, names.first))
    
    File.should.exist?(dirname)
    names.each { |full_name, description_filename| KaridocGenerator.clear(@manager.filepath, full_name) }
    File.should.not.exist(dirname)
  end
  
  it "should silently ignore clearing missing documentation directories" do
    names = ['Binding#clone']*3
    lambda {
      names.each { |full_name, description_filename| KaridocGenerator.clear(@manager.filepath, full_name) }
    }.should.not.raise
  end
end

describe "A KaridocGenerator" do
  extend TemporaryApplicationSupportPath
  extend FixtureHelpers
  
  before do
    @karidoc_path = File.join(Kari.application_support_path, 'Karidoc.6345.1')
    @generator = KaridocGenerator.new(@karidoc_path, [
      file_fixture('normal', 'ri', 'Binding', 'cdesc-Binding.yaml'),
      file_fixture('alternate', 'ri', 'Binding', 'cdesc-Binding.yaml')
    ])
  end
  
  it "should generate" do
    filename = @generator.generate
    filename.should == '/Binding.karidoc'
    generated = File.read(File.join(@karidoc_path, filename))
    generated.should =~ /<title>Binding<\/title>/
    generated.should =~ %r%<link href="KaridocAssets/karidoc.css"%
  end
  
  it "should render ri descriptions" do
    result = @generator.render([YAML::load_file(@generator.description_files.first)], :relative_path_to_root => '../..')
    result.should =~ /<title>Binding<\/title>/
  end
  
  it "should generate when there are missing YAML descriptions" do
     @generator.description_files << file_fixture('missing', 'Binding', 'cdesc-Binding.yaml')
     lambda {
       @generator.generate
     }.should.not.raise(Errno::ENOENT)
  end
  
  it "should not generate when all YAML descriptions are missing" do
    @generator.description_files = []
    @generator.generate.should.be.nil
  end
  
  it "should know it's assets path" do
    @generator.karidoc_asset_path.should.start_with(@karidoc_path)
    @generator.karidoc_asset_path.should.end_with('KaridocAssets')
  end
  
  it "should freeze it's assets to the karidoc path" do
    File.should.not.exist(@generator.karidoc_asset_path)
    @generator.freeze_assets
    Dir.entries(@generator.karidoc_asset_path).sort.should == (%w(. ..)+KaridocGenerator::ASSETS).sort
  end
end