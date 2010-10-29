require File.expand_path('../../spec_helper', __FILE__)
require 'fileutils'
require 'benchmark'

class ManagerTestCache
  BASE_PATH_CACHE = File.join(Dir.tmpdir, 'kari-integration-tests', 'cache')
  BASE_PATH_TMP   = File.join(Dir.tmpdir, 'kari-integration-tests', 'tmp')
  RI_BALL         = File.join(TEST_ROOT_PATH, 'fixtures', 'regression-ri.tar.bz2')
  
  class << self
    def base_path
      BASE_PATH_TMP
    end
    
    def ri_path
      File.join(base_path, 'regression-ri')
    end
    
    def application_support_path
      File.join(base_path, 'application-support')
    end
    
    def cache_age
      File.exist?(BASE_PATH_CACHE) ? File.atime(BASE_PATH_CACHE) - Time.now : 0
    end
    
    def stale?
      !ENV['REFRESH'].nil? or !File.exist?(BASE_PATH_CACHE) or cache_age > (15*60)
    end
    
    def bootstrap
      t('b')
      FileUtils.rm_rf(BASE_PATH_TMP)
      FileUtils.rm_rf(BASE_PATH_CACHE)
      
      FileUtils.mkdir_p(base_path)
      FileUtils.mkdir_p(application_support_path)
      
      `cd #{base_path} && tar -xjf #{RI_BALL}`
      
      manager = Manager.new
      manager.examine(ri_path)
      manager.write_to_disk
      manager.update_symlink
      manager.close
      
      FileUtils.cp_r(BASE_PATH_TMP, BASE_PATH_CACHE)
    end
    
    def copy
      t('c')
      FileUtils.touch(BASE_PATH_CACHE)
      FileUtils.rm_rf(BASE_PATH_TMP)
      `cp -R #{BASE_PATH_CACHE} #{BASE_PATH_TMP}`
    end
    
    def setup_manager
      Kari.stubs(:application_support_path).returns(application_support_path)
      if stale?
        bootstrap
      else
        copy
      end
      @manager = Manager.initialize_from_disk
    end
    
    def teardown_mananger
      @manager.close
    end
    
    def t(*args)
      $stdout.write(*args)
      $stdout.flush
    end
    
    def b
      m = Benchmark.measure do
        yield
      end
      t(m.real.round)
    end
    
    def l(path)
      puts "{!} Files in #{path}"
      if File.exist?(path)
        Find.find(path) do |filename|
          puts "#{filename} (#{File.ftype(filename)})"
        end
      else
        puts "  - #{path} doesn't exist at the moment"
      end
    end
  end
end

describe "A Manager" do
  before do
    show_backtrace do
      @manager = ManagerTestCache.setup_manager
    end
  end
  
  after do
    ManagerTestCache.teardown_mananger
  end
  
  it "should update indices when a gem version disappears" do
    @manager.descriptions['REST::Request'].length.should == 2
    @manager.namespace.get(['REST', 'Request']).should.end_with('Request.karidoc')
    
    nap_gem_directory = File.join(ManagerTestCache.ri_path, 'nap-0.1')
    File.should.exist?(nap_gem_directory)
    FileUtils.rm_rf(nap_gem_directory)
    
    @manager.examine(ManagerTestCache.ri_path)
    
    @manager.descriptions['REST::Request'].length.should == 1
    @manager.namespace.get(['REST', 'Request']).should.end_with('Request.karidoc')
    
    # TODO: test the SKIndex contents
  end
  
  it "should update indices when a gem disappears" do
    @manager.descriptions['REST::Request'].length.should == 2
    @manager.namespace.get(['REST', 'Request']).should.end_with('Request.karidoc')
    
    nap_gem_directory = File.join(ManagerTestCache.ri_path, 'nap-0.1')
    File.should.exist?(nap_gem_directory)
    FileUtils.rm_rf(nap_gem_directory)
    
    nap_gem_directory = File.join(ManagerTestCache.ri_path, 'nap-0.2')
    File.should.exist?(nap_gem_directory)
    FileUtils.rm_rf(nap_gem_directory)
    
    @manager.examine(ManagerTestCache.ri_path)
    
    @manager.descriptions['REST::Request'].should.be.nil
    @manager.namespace.get(['REST', 'Request']).should.be.nil
    
    # TODO: test the SKIndex contents
  end
  
  it "should update indices when a gem version appears" do
    @manager.descriptions['REST::Request'].length.should == 2
    @manager.namespace.get(['REST', 'Request']).should.end_with('Request.karidoc')
    
    source_directory = File.join(ManagerTestCache.ri_path, 'nap-0.2')
    destination_directory = File.join(ManagerTestCache.ri_path, 'nap-0.3')
    FileUtils.cp_r(source_directory, destination_directory)
    
    @manager.examine(ManagerTestCache.ri_path)
    
    @manager.descriptions['REST::Request'].length.should == 3
    @manager.namespace.get(['REST', 'Request']).should.end_with('Request.karidoc')
    
    # TODO: test the SKIndex contents
  end
end