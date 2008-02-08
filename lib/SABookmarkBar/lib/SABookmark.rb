class OSX::SABookmark < OSX::NSObject
  attr_accessor :id, :title, :url, :order_index
  
  class << self
    def createWithHash(options)
      @@bookmarks ||= {}
      id = @@bookmarks.empty? ? 0 : @@bookmarks.keys.sort.last.next
      order_index = @@bookmarks.length
      return self.alloc.initWithHash(options.merge({:id => id, :order_index => order_index}))
    end
    
    def bookmarkForID(id)
      @@bookmarks[id]
    end
  end
  
  def initWithHash(options)
    if self.init
      @id, @title, @url, @order_index = options[:id].to_i, options[:title].to_s, options[:url].to_s, options[:order_index].to_i
      
      @@bookmarks ||= {}
      @@bookmarks[@id] = self
      
      return self
    end
  end
  
  def to_hash
    { :id => @id, :title => @title, :url => @url, :order_index => @order_index }
  end
end