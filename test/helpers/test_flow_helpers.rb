require File.expand_path('../../test_helper', __FILE__)

describe "A class including FlowHelpers" do
  include HTMLHelpers
  include FlowHelpers
  
  it "should format a flow" do
    flow([]).should == ''
    flow([SM::Flow::P.new('Description')]).should == '<p>Description</p>'
    flow([SM::Flow::P.new('Description')]*2).should == '<p>Description</p>'*2
  end
  
  it "should format a flow list" do
    flow_list(stub(:contents => [])).should == '<ul></ul>'
    flow_list(stub(:contents => [SM::Flow::LI.new('*', 'Description')])).should == '<ul><li>Description</li></ul>'
  end
  
  it "should format flow parts" do
    flow_part(SM::Flow::P.new('Description')).should == '<p>Description</p>'
    flow_part(SM::Flow::LI.new('*', 'Name')).should == '<li>Name</li>'
    flow_part(SM::Flow::VERB.new('[]')).should == '<pre>[]</pre>'
    flow_part(SM::Flow::H.new(1, 'Title')).should == '<h3>Title</h3>'
    flow_part(SM::Flow::RULE.new).should == '<hr />'
    
    list = SM::Flow::LIST.new(SM::ListBase::BULLET)
    list << SM::Flow::LI.new('*', 'Name')
    list << SM::Flow::LI.new('*', 'Name')
    flow_part(list).should == '<ul><li>Name</li><li>Name</li></ul>'
  end
end