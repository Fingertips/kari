module SearchKit
  class Index < OSX::NSObject
    def self.create(path, name=nil, type=OSX::KSKIndexInverted)
      alloc.initWithIndex(OSX::SKIndexCreateWithURL(OSX::NSURL.fileURLWithPath(path), name, type, nil))
    end
    
    def self.open(path, name=nil, allow_updating=false, &block)
      index = alloc.initWithIndex(OSX::SKIndexOpenWithURL(OSX::NSURL.fileURLWithPath(path), name, allow_updating))
      if block
        begin
          yield index
        ensure
          index.close
        end
      else
        index
      end
    end
    
    def initWithIndex(index)
      if init
        @index = index
        self
      end
    end
    
    def close
      OSX::SKIndexClose(@index)
    end
    
    def addDocument(path)
      url = OSX::NSURL.fileURLWithPath(path)
      document = OSX::SKDocumentCreateWithURL(url)
      # FIXME: the third param is a MIMETypeHint that is used to select a SpotLight importer
      OSX::SKIndexAddDocument(@index, document, nil, true)
    end
  end
end