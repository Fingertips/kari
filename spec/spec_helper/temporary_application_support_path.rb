module TemporaryApplicationSupportPath
  def self.extended(base)
    base.before do
      @application_support_path = TemporaryApplicationSupportPath.stub
      TemporaryApplicationSupportPath.cleanup(@application_support_path)
    end
    base.after do
      TemporaryApplicationSupportPath.cleanup(@application_support_path)
    end
  end
  
  def self.stub
    application_support_path = File.join(Dir.tmpdir, 'kari-application-support-path')
    Kari.stubs(:application_support_path).returns(application_support_path)
    application_support_path
  end
  
  def self.cleanup(path)
    FileUtils.rm_rf(path)
  end
end