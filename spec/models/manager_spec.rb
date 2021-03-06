require File.expand_path('../../spec_helper', __FILE__)

PRIMARY_RI_PATH = File.join(TEST_ROOT_PATH, 'fixtures', 'normal', 'ri')
ALTERNATE_RI_PATH = File.join(TEST_ROOT_PATH, 'fixtures', 'alternate', 'ri')

module ManagerHelper
  def remove_manager_singleton!
    Manager.instance_variable_set(:@instance, nil)
  end
end

describe "Manager" do
  extend TemporaryApplicationSupportPath
  extend ManagerHelper
  
  after do
    remove_manager_singleton!
  end
  
  it "should initialize from marshaled disk image" do
    index = Manager.initialize_from_disk
    index.length.should == 0
    index.close
  end
  
  it "should always return the same singleton instance" do
    remove_manager_singleton!
    Manager.instance.object_id.should == Manager.instance.object_id
  end
  
  it "should generate file paths for Karidoc" do
    file_path = Manager.generate_filepath(0)
    file_path.should.start_with?(@application_support_path)
    file_path.should.end_with?('0')
    
    file_path = Manager.generate_filepath(10)
    file_path.should.start_with?(@application_support_path)
    file_path.should.end_with?('10')
  end
  
  it "should find the next usable file path for Karidoc" do
    FileUtils.mkdir_p(file_path = Manager.next_filepath)
    file_path.should.start_with?(@application_support_path)
    file_path.should.end_with?('0')
    
    FileUtils.mkdir_p(file_path = Manager.next_filepath)
    file_path.should.start_with?(@application_support_path)
    file_path.should.end_with?('1')
  end
  
  it "should return the location where to search the current Karidocs" do
    Manager.current_filepath.should.start_with?(@application_support_path)
    Manager.current_filepath.should.end_with?('Karidoc.current')
  end
  
  it "should know which Karidoc directories are stale" do
    Manager.stale_karidocs.should.be.nil
    
    created = []
    5.times { FileUtils.mkdir_p(created << Manager.next_filepath) }
    FileUtils.ln_s(created.last, Manager.current_filepath)
    
    Manager.stale_karidocs.sort.should == (created-[created.last]).sort
  end
  
  it "should cleanup stale Karidoc directories" do
    support_path = Kari.application_support_path
    symlink = File.basename(Manager.current_filepath)
    
    created = []
    5.times do
      FileUtils.mkdir_p(created << Manager.next_filepath)
    end
    FileUtils.ln_s(created[2], Manager.current_filepath)
    FileUtils.touch(File.join(support_path, 'BrowseHistory'))
    
    Dir.entries(support_path).sort.should == ['.', '..', symlink, 'BrowseHistory', *created.map { |c| File.basename(c) }].sort
    Manager.cleanup
    Dir.entries(support_path).sort.should == ['.', '..', symlink, 'BrowseHistory', File.basename(created[2])].sort
  end
  
  it "should not cleanup stale Karidoc directories when there are none" do
    Manager.stubs(:stale_karidocs).returns(nil)
    FileUtils.expects(:rm_rf).at_most(1) # After block calls rm_rf
    Manager.cleanup
  end
  
  it "should know when it's the first run" do
    Manager.should.be.first_run
  end
  
  it "should know when it's not the first run" do
    FileUtils.mkdir_p(Manager.current_filepath)
    Manager.should.not.be.first_run
  end
  
  it "should bootstrap the manager on first run" do
    Manager.should.be.first_run
    
    manager = Manager.bootstrap
    
    manager.length.should == 9102
    Manager.should.not.be.first_run
    Manager.instance.should === manager
  end
end

describe "A Manager" do
  extend TemporaryApplicationSupportPath
  
  before do
    @manager = Manager.new
  end
  
  after do
    @manager.close
  end
  
  it "should not break when RI has descriptions with an empty full name (workaround for a bug)" do
    lambda {
      @manager.add('', '/path/to/cdesc-.yml')
      @manager.add('#JSON', '/path/to/JSON/JSON-i.yml')
    }.should.not.raise
  end
  
  it "should freeze Karidoc assets after updating the Karidoc documentation" do
    @manager.stubs(:update).returns([])
    @manager.stubs(:update_karidoc)
    KaridocGenerator.expects(:freeze_assets).with(@manager.filepath)
    @manager.examine('/path/to/ri')
  end
end

describe "An empty Manager" do
  extend TemporaryApplicationSupportPath
  extend FixtureHelpers
  
  before do
    @manager = Manager.new
  end
  
  after do
    @manager.close
  end
  
  it "should return the number of indexed entries" do
    @manager.length.should == 0
  end
  
  it "should write the current index to disk" do
    @manager.stubs(:filepath).returns(Dir::tmpdir)
    @manager.write_to_disk
    @manager.should.exist
    File.unlink(@manager.filename)
  end
  
  it "should add descriptions to the namespace" do
    @manager.add_karidoc_to_namespace('Module::Class#method')
    @manager.add_karidoc_to_namespace('Module::Class::classmethod')
    @manager.add_karidoc_to_namespace('Module2::Class#othermethod')
    @manager.namespace.empty?.should == false
    @manager.namespace.get(%w(Module Class #method)).should.not.be.nil
    @manager.namespace.get(%w(Module Class classmethod)).should.not.be.nil
    @manager.namespace.get(%w(Module2 Class #othermethod)).should.not.be.nil
  end
  
  it "should add description to the index" do
    @manager.add_description('Module::Class#method', '/path/to/ri/Module/Class/method-i.yaml')
    @manager.add_description('Module::Class::classmethod', '/path/to/ri/Module/Class/classmethod-c.yaml')
    @manager.add_description('Module::Class::classmethod', '/path/to_other/ri/Module/Class/classmethod-c.yaml')
    @manager.descriptions["Module::Class#method"].length.should == 1
    @manager.descriptions["Module::Class::classmethod"].length.should == 2
  end
  
  it "should sort system descriptions before non-system descriptions and newer gems before older gems" do
    paths = [
      File.join(Manager::SYSTEM_RI_PATH, 'doc', 'ri', 'cdesc-String.yaml'),
      File.join('path', 'to',          'mygem-0.3.1', 'ri', 'cdesc-String.yaml'),
      File.join('other', 'path', 'to', 'mygem-0.2', 'ri', 'cdesc-String.yaml'),
      File.join('path', 'to',          'mygem-0.1.2.1', 'ri', 'cdesc-String.yaml'),
    ]
    @manager.add_description('String', paths[3])
    @manager.add_description('String', paths[0])
    @manager.add_description('String', paths[1])
    @manager.add_description('String', paths[2])
    
    @manager.descriptions["String"].should == paths
  end
  
  it "should add descriptions found in description files" do
    @manager.examine(PRIMARY_RI_PATH)
    @manager.descriptions.has_key?('Binding').should == true
    @manager.namespace.get(%w(Binding #dup)).should.not.be.nil
    
    @manager.descriptions.length.should == 11
    @manager.descriptions["Binding#dup"].length.should == 1
    @manager.descriptions["Binding#clone"].length.should == 1
  end
  
  it "should merge multiple descriptions" do
    @manager.examine(PRIMARY_RI_PATH)
    @manager.examine(ALTERNATE_RI_PATH)
    
    @manager.descriptions.length.should == 11
    @manager.descriptions["Binding#dup"].length.should == 2
    @manager.descriptions["Binding#clone"].length.should == 1
  end
  
  it "should add new descriptions for classes" do
    @manager.add('Binding', file_fixture('normal', 'ri', 'Binding', 'cdesc-Binding.yaml'))
    @manager.descriptions['Binding'].should.not.be.nil
    @manager.namespace.get(['Binding']).should.not.be.nil
  end
  
  it "should add and update documents to/in the index" do
    %w{ Binding.karidoc Binding/#dup.karidoc }.each do |file|
      karidoc_filename = File.join('', file)
      
      @manager.search_index.expects(:removeDocument).with(karidoc_filename)
      @manager.search_index.expects('addDocument:withText:')
    end
    @manager.examine(ALTERNATE_RI_PATH)
  end
  
  it "should remove documents from the index" do
    @manager.search_index.expects(:removeDocument).with(File.join('', 'Binding', '#clone.karidoc'))
    @manager.search_index.expects('addDocument:withText:').never
    @manager.update_karidoc(['Binding#clone'])
  end
end

describe "A filled Manager" do
  extend TemporaryApplicationSupportPath
  
  before do
    @manager = Manager.new
    @manager.examine(PRIMARY_RI_PATH)
  end
  
  after do
    @manager.close
  end
  
  it "should remove descriptions when removed from the filesystem" do
    File.stubs(:exist?).returns(false)
    @manager.purge_vanished(PRIMARY_RI_PATH)
    
    @manager.descriptions['Binding'].should.be.nil
    @manager.descriptions['Binding#clone'].should.be.nil
    @manager.descriptions['Binding#dub'].should.be.nil
    
    @manager.namespace.get(%w(Binding)).should.be.nil
    @manager.namespace.get(%w(Binding #clone)).should.be.nil
    @manager.namespace.get(%w(Binding #dup)).should.be.nil
  end
  
  it "should not remove descriptions when an alternate descriptions still exists" do
    @manager.merge_new(ALTERNATE_RI_PATH)
    File.stubs(:exist?).returns(false)
    @manager.purge_vanished(PRIMARY_RI_PATH)
    
    @manager.descriptions['Binding'].should.not.be.nil
    @manager.descriptions['Binding#dup'].should.not.be.nil
    @manager.descriptions['Binding#clone'].should.be.nil
    
    @manager.namespace.get(%w(Binding)).should.not.be.nil
    @manager.namespace.get(%w(Binding #clone)).should.be.nil
    @manager.namespace.get(%w(Binding #dup)).should.not.be.nil
  end
  
  # DISABLED somehow this triggers a reference count problem in MacRuby and I don't wanna…
  # it "should be able to write index to disk and read it back" do
  #     @manager.write_to_disk
  #     @manager.close
  #     
  #     manager = Manager.initialize_from_disk
  #     manager.descriptions.should == @manager.descriptions
  #     manager.namespace.should == @manager.namespace
  # end
  
  it "should forward search queries to the Search Kit Index instance" do
    @manager.search_index.expects(:search).with('a pot of gold')
    @manager.search('a pot of gold')
  end
  
  it "should not break when updating the Karidocs and all YAML description turn out to be missing" do
    lambda {
      @manager.descriptions['Binding'] = ['/missing', '/missing', '/missing']
      @manager.update_karidoc(['Binding'])
    }.should.not.raise
  end
  
  it "should symlink the created Karidocs to the current Karidocs" do
    File.should.not.exist(Manager.current_filepath)
    @manager.update_symlink
    File.should.exist(Manager.current_filepath)
    @manager.update_symlink
    File.should.exist(Manager.current_filepath)
  end
end