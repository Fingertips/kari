class ClassTreeController < NSTreeController
  def setSelectionRubyName(rubyName)
    indices = Manager.instance.namespace.indices_for_path(RubyName.split(rubyName))
    indexPath = NSIndexPath.indexPathWithIndexes(indices, length:indices.length)
    setSelectionIndexPath(indexPath)
  end
end