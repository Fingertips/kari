class ClassTreeController < OSX::NSTreeController
  def setSelectionRubyName(rubyName)
    indices = Manager.instance.namespace.indices_for_path(RubyName.split(rubyName))
    indexPath = OSX::NSIndexPath.indexPathWithIndexes_length(indices, indices.length)
    setSelectionIndexPath(indexPath)
  end
end