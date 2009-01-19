class Bookmark < OSX::NSObject
  attr_accessor :id, :title, :url, :order_index
  
  def self.createWithHash(options)
    @@bookmarks ||= {}
    id = @@bookmarks.empty? ? 0 : @@bookmarks.keys.sort.last.next
    order_index = @@bookmarks.length
    self.alloc.initWithHash(options.merge({:id => id, :order_index => order_index}))
  end
  
  def self.[](id)
    @@bookmarks[id]
  end
  
  def self.reset!
    @@bookmarks = {}
  end
  
  def initWithHash(options)
    if self.init
      @id          = options[:id].to_i
      @title       = options[:title].to_s
      @url         = options[:url].to_s
      @order_index = options[:order_index].to_i
      
      @@bookmarks ||= {}
      @@bookmarks[@id] = self
      
      self
    end
  end
  
  def <=>(other)
    if other.respond_to?(:order_index)
      order_index <=> other.order_index
    else
      super
    end
  end
  
  def to_hash
    { :id => @id, :title => @title, :url => @url, :order_index => @order_index }
  end
end