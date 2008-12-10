module SearchKit
  Match = OSX::Match
  
  class Match < OSX::NSObject
    kvc_accessor :name
    
    def name
      @name ||= RubyName.from_karidoc_filename(self.URL.path)
    end
    objc_method :name, [:id]
  end
end