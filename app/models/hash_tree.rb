class HashTree
  def initialize
    @tree = { :value => :root, :children => {} }
  end
  
  def empty?
    @tree[:children].empty?
  end
  
  def set(value, path, at=nil)
    at ||= @tree
    head = path.first
    rest = path[1..-1]
    
    at[:children][head] ||= { :value => nil, :children => {} }
    unless rest.empty?
      set(value, rest, at[:children][head])
    else
      at[:children][head][:value] = value
    end
  end
  
  def get(path, at=nil)
    at ||= @tree
    head = path.first
    rest = path[1..-1]
    
    unless rest.empty?
      get(rest, at[:children][head])
    else
      at[:children][head][:value] if at[:children].has_key?(head)
    end
  end
  
  def prune(path)
    at ||= @tree
    head = path.first
    rest = path[1..-1]
    
    unless rest.empty?
      prune(rest, at[:children][head])
    else
      at[:children].delete(head)
    end
  end
end