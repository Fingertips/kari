class ClassTreeNode
  class << self
    def classTreeNodesWithHash_path(hash, at)
      return [] if hash.empty?
      
      hash[:children].map do |klass, values|
        alloc.initWithHash_path(values, at + [klass])
      end.sort_by { |node| node.title }
    end
    
    def classTreeNodesWithHashTree(hash_tree)
      classTreeNodesWithHash_path(hash_tree.tree, [])
    end
  end
  
  attr_accessor :children, :title
  attr_reader :tree, :at
  
  def initWithHash_path(tree, at)
    if init
      @tree, @at = tree, at
      self
    end
  end
  
  def title
    @at.last
  end
  
  def path
    @tree[:value]
  end
  
  def children
    @children ||= ClassTreeNode.classTreeNodesWithHash_path(@tree, @at)
  end
  
  def ==(other)
    @tree == other.tree and @at == other.at
  end
end