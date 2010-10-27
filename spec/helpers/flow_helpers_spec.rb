require File.expand_path('../../spec_helper', __FILE__)

describe "A class including FlowHelpers" do
  extend HTMLHelpers
  extend FlowHelpers
  
  it "should format a flow" do
    flow([]).should == ''
    flow([RDoc::Markup::Flow::P.new('Description')]).should == '<p>Description</p>'
    flow([RDoc::Markup::Flow::P.new('Description')]*2).should == '<p>Description</p>'*2
  end
  
  it "should format a flow list" do
    flow_list(stub(:contents => [])).should == '<ul></ul>'
    flow_list(stub(:contents => [RDoc::Markup::Flow::LI.new('*', 'Description')])).should == '<ul><li>Description</li></ul>'
  end
  
  it "should format flow parts" do
    flow_part(RDoc::Markup::Flow::P.new('Description')).should == '<p>Description</p>'
    flow_part(RDoc::Markup::Flow::LI.new('*', 'Name')).should == '<li>Name</li>'
    flow_part(RDoc::Markup::Flow::VERB.new('[]')).should == '<pre>[]</pre>'
    flow_part(RDoc::Markup::Flow::H.new(1, 'Title')).should == '<h3>Title</h3>'
    flow_part(RDoc::Markup::Flow::RULE.new).should == '<hr />'
    
    list = RDoc::Markup::Flow::LIST.new(:BULLET)
    list << RDoc::Markup::Flow::LI.new('*', 'Name')
    list << RDoc::Markup::Flow::LI.new('*', 'Name')
    flow_part(list).should == '<ul><li>Name</li><li>Name</li></ul>'
  end
end