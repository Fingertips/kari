require File.expand_path('../../test_helper', __FILE__)
require 'fileutils'

class ManagerTestCache
  BASE_PATH_CACHE = File.join(Dir.tmpdir, 'kari-integration-tests', 'cache')
  BASE_PATH_TMP   = File.join(Dir.tmpdir, 'kari-integration-tests', 'tmp')
  RI_BALL         = File.join(TEST_ROOT, 'fixtures', 'regression-ri.tar.bz2')
  
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
      File.atime(BASE_PATH_CACHE) - Time.now
    end
    
    def stale?
      puts "[!] Forced refresh" if !ENV['REFRESH'].nil?
      puts "[!] Cache doesn't exist" if !File.exist?(BASE_PATH_CACHE)
      puts "[!] Cache is too old: #{cache_age} > #{(15*60)}" if cache_age > (15*60)
      
      !ENV['REFRESH'].nil? or !File.exist?(BASE_PATH_CACHE) or cache_age > (15*60)
    end
    
    def bootstrap
      puts "[!] Bootstrapping the Manager cache"
      FileUtils.rm_rf(BASE_PATH_TMP)
      FileUtils.rm_rf(BASE_PATH_CACHE)
      
      FileUtils.mkdir_p(base_path)
      FileUtils.mkdir_p(application_support_path)
      
      `cd #{base_path} && tar -xjf #{RI_BALL}`
      
      manager = Manager.new
      manager.examine(ri_path)
      manager.write_to_disk
      manager.close
      
      FileUtils.cp_r(BASE_PATH_TMP, BASE_PATH_CACHE)
    end
    
    def copy
      FileUtils.touch(BASE_PATH_CACHE)
      FileUtils.rm_rf(BASE_PATH_TMP)
      FileUtils.cp_r(BASE_PATH_CACHE, BASE_PATH_TMP)
    end
    
    def setup_manager
      Rucola::RCApp.stubs(:application_support_path).returns(application_support_path)
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
  end
end

describe "A Manager" do
  before do
    @manager = ManagerTestCache.setup_manager
  end
  
  after do
    ManagerTestCache.teardown_mananger
  end
  
  it "should update indices when a gem verion disappears" do
    @manager.descriptions['REST::Request'].length.should == 2
    @manager.namespace.get(['REST', 'Request']).should == KaridocGenerator.filename('REST::Request')
    
    nap_gem_directory = File.join(ManagerTestCache.ri_path, 'nap-0.1')
    File.should.exist?(nap_gem_directory)
    FileUtils.rm_rf(nap_gem_directory)
    
    @manager.examine(ManagerTestCache.ri_path)
    @manager.descriptions['REST::Request'].length.should == 1
    @manager.namespace.get(['REST', 'Request']).should == KaridocGenerator.filename('REST::Request')
    
    # TODO: test the SKIndex contents
  end
  
  it "should update indices when a gem disappears" do
    @manager.descriptions['REST::Request'].length.should == 2
    @manager.namespace.get(['REST', 'Request']).should == KaridocGenerator.filename('REST::Request')
    
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
  
  # it "should update indices when a gem appears" do
  # end
end