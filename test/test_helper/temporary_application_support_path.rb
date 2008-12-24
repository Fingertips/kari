module TemporaryApplicationSupportPath
  def self.included(base)
    base.send(:before) do
      TemporaryApplicationSupportPath.stub
    end
    base.send(:after) do
      TemporaryApplicationSupportPath.cleanup
    end
  end
  
  def self.stub
    @application_support_path = File.join(Dir.tmpdir, 'kari-application-support-path')
    Rucola::RCApp.stubs(:application_support_path).returns(@application_support_path)
  end
  
  def self.cleanup
    FileUtils.rm_rf(@application_support_path)
  end
end