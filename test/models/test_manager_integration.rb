require File.expand_path('../../test_helper', __FILE__)
require 'fileutils'

describe "A Manager" do
  include TemporaryApplicationSupportPath
  include FixtureHelpers
  
  RI_BALL = File.join(TEST_ROOT, 'fixtures', 'regression-ri.tar.bz2')
  RI_PATH = File.join(Dir.tmpdir, 'regression-test')
  
  before do
    FileUtils.mkdir_p(RI_PATH)
    `cd #{RI_PATH} && tar -xjf #{RI_BALL}`
    
    @manager = Manager.new
    @manager.examine(RI_PATH)
  end
  
  after do
    @manager.close
    FileUtils.rm_rf(RI_PATH)
  end
  
  it "should update indices when a gem disappears" do
  end
  
  it "should update indices when a gem appears" do
  end
end