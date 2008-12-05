class ClassTreeNode < OSX::NSObject
  kvc_accessor :children, :title

  def initWithHashTree_path(tree, at = [])
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
      @children = @at.empty? ? {}.to_ns : @tree.get(@at).to_ns
      p @children
      #@children = entries.map { |name| ClassList.alloc.initWithSomeArgs(@at + [name]) }
    end
    @children
  end
end