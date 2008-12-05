class ClassTreeNode < OSX::NSObject
  def self.classTreeNodesWithHashTree(hash_tree)
    nodes = hash_tree.tree[:children].map do |klass, values|
      alloc.initWithHash_path(values, [klass])
    end
    nodes
  end
  
  kvc_accessor :children, :title
  attr_reader :tree, :at

  def initWithHash_path(tree, at)
    if init
      @tree, @at = tree, at
      self
    end
  end

  def title
    @at.last || 'Root'
  end

  def children
    if @children.nil?
      @children = @tree[:children].map do |klass, values|
        ClassTreeNode.alloc.initWithHash_path(values, @at + [klass])
      end
    end
    @children
  end
end