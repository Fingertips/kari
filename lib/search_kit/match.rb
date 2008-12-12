module SearchKit
  Match = OSX::Match
  
  class Match < OSX::NSObject
    kvc_accessor :name
    
    def name
      @name ||= RubyName.from_karidoc_filename(self.URL.path)
    end
    objc_method :name, [:id]
    
    def inspect
      "#<SearchKit::Match:#{object_id} name=#{name} url=#{self.URL.path} score=#{score}>"
    end
  end
end