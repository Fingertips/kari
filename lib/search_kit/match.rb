module SearchKit
  Match = OSX::Match
  
  class Match < OSX::NSObject
    kvc_accessor :name
    
    def name
      @name ||= RubyName.from_karidoc_path(URL().path)
    end
    objc_method :name, [:id]
    
    def filename
      OSX::NSURL.fileURLWithPath(File.join(Rucola::RCApp.application_support_path, URL().path))
    end
    
    def inspect
      "#<SearchKit::Match:#{object_id} name=#{name} url=#{URL().path} score=#{score}>"
    end
  end
end