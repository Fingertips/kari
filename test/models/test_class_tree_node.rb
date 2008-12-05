require File.expand_path('../../test_helper', __FILE__)

describe "A ClassTreeNode, in general" do
  before do
    tree = HashTree.new
    tree.set(%w(Kernel), 'Karidoc/Kernel.karidoc')
    tree.set(%w(Kernel Fun dup), 'Karidoc/Kernel/Fun/dup.karidoc')
    @node = ClassTreeNode.classTreeNodesWithHashTree(tree).first
  end
  
  it "should return its title" do
    @node.title.should == 'Kernel'
  end
  
  it "should return its children as ClassTreeNode objects" do
    child = @node.children.first
    child.should.be.instance_of ClassTreeNode
    child.title.should == 'Fun'
  end
  
  it "should always return the same array instance when returning children" do
    @node.children.should.be @node.children
  end
  
  it "should return the path to its karidoc" do
    @node.path.should == 'Karidoc/Kernel.karidoc'
    @node.children.first.children.first.path.should == 'Karidoc/Kernel/Fun/dup.karidoc'
  end
end

describe "A ClassTreeNode's class methods" do
  before do
    @tree = HashTree.new
    @tree.set(%w(Kernel Fun dup), 'Kernel::Fun#dup')
    @tree.set(%w(Binding clone), 'Binding#clone')
    @tree.set(%w(Binding dup), 'Binding#dup')
    
    @nodes = ClassTreeNode.classTreeNodesWithHash_path(@tree.tree, [])
  end
  
  it "should return an empty array for an empty tree hash" do
    ClassTreeNode.classTreeNodesWithHash_path({}, []).should == []
  end
  
  it "should return an array of ClassTreeNode's for all children in a tree Hash" do
    @nodes.each { |node| node.should.be.instance_of ClassTreeNode }
    @nodes.length.should.be 2
  end
  
  it "should have sorted the nodes by title" do
    @nodes.first.title.should == 'Binding'
    @nodes.last.title.should == 'Kernel'
  end
  
  it "should return an array of ClassTreeNode's for all root children in a HashTree" do
    nodes = ClassTreeNode.classTreeNodesWithHashTree(@tree)
    nodes.should == ClassTreeNode.classTreeNodesWithHash_path(@tree.tree, [])
  end
end