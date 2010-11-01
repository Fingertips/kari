class ApplicationController
  def setup_classTree!
    self.class_tree = ClassTreeNode.classTreeNodesWithHashTree(Manager.instance.namespace)
    @classTreeController.addObserver(self,
       forKeyPath: 'selectionIndexPaths',
          options: NSKeyValueObservingOptionNew,
          context: nil
    )
  end
end