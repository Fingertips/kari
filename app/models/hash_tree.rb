class HashTree
  def initialize
    @tree = { :children => {} }
  end
  
  def empty?
    @tree[:children].empty?
  end
  
  def set(path, value, at=nil)
    at ||= @tree
    head = path.first
    rest = path[1..-1]
    
    at[:children][head] ||= { :value => nil, :children => {} }
    unless rest.empty?
      set(rest, value, at[:children][head])
    else
      at[:children][head][:value] = value
      # We don't have a value anymore so if there aren't any children this node should be deleted
      if value.nil? and at[:children][head][:children].empty?
        at[:children].delete(head)
      end
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