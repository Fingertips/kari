require File.expand_path('../../spec_helper', __FILE__)

describe "A HashTree in general" do
  before do
    @tree = HashTree.new
    @tree.set(%w(Binding clone), 'Binding#clone')
    @tree.set(%w(Binding dup), 'Binding#dup')
    @tree.set(%w(Kernel Fun dup), 'Kernel::Fun#dup')
  end
  
  it "should get the same value that was set on a certain path" do
    path = %w(Binding)
    @tree.set(path, path.last)
    @tree.get(path).should == path.last
    
    path = %w(Binding Immediate dup)
    @tree.set(path, path.last)
    @tree.get(path).should == path.last
  end
  
  it "should prune a subtree but leave the rest intact" do
    @tree.prune(%w(Binding))
    
    @tree.get(%w(Binding)).should.be.nil
    @tree.get(%w(Binding clone)).should.be.nil
    @tree.get(%w(Binding dup)).should.be.nil
    @tree.get(%w(Kernel Fun dup)).should.not.be.nil
  end
  
  it "should prune a subtree when the last children disappear and the value is nil" do
    @tree.prune(%w(Binding clone))
    @tree.prune(%w(Binding dup))
    
    @tree.get(%w(Binding clone)).should.be.nil
    @tree.get(%w(Binding dup)).should.be.nil
    @tree.get(%w(Binding)).should.be.nil
    @tree.get(%w(Kernel Fun dup)).should.not.be.nil
  end
  
  it "should not prune a subtree when the last children disappear, but the value isn't nil" do
    @tree.set(%w(Binding), 'Binding')
    
    @tree.prune(%w(Binding clone))
    @tree.prune(%w(Binding dup))
    
    @tree.get(%w(Binding clone)).should.be.nil
    @tree.get(%w(Binding dup)).should.be.nil
    @tree.get(%w(Binding)).should.not.be.nil
    @tree.get(%w(Kernel Fun dup)).should.not.be.nil
  end
  
  it "should know it's not empty" do
    @tree.empty?.should == false
  end
  
  it "should be equal to itself" do
    @tree.should == @tree
  end
  
  it "should return a list of indices to a certain path" do
    @tree.indices_for_path(%w(Binding clone)).should == [0, 0]
    @tree.indices_for_path(%w(Binding dup)).should == [0, 1]
    @tree.indices_for_path(%w(Kernel Fun dup)).should == [1, 0, 0]
  end
end

describe "An empty HashTree" do
  before do
    @tree = HashTree.new
  end
  
  it "should know it's empty" do
    @tree.empty?.should == true
  end
  
  it "should not be empty after adding something" do
    @tree.set(%w(Binding), 'Binding')
    @tree.empty?.should == false
  end
  
  it "should be equal to any other empty HashTree" do
    @tree.should == HashTree.new
  end
end