require File.expand_path('../../spec_helper', __FILE__)

module HTMLHelpersHelper
  attr_accessor :partials
end

describe "A class including HTMLHelpers" do
  extend HTMLHelpers
  
  it "should create attributes for a tag from a hash" do
    tag_attributes.should == ''
    tag_attributes({}).should == ''
    tag_attributes(:class => 'un"active').should == ' class="un&quot;active"'
    tag_attributes(:class => 'un<active').should == ' class="un&lt;active"'
    tag_attributes(:class => 'unactive').should == ' class="unactive"'
    tag_attributes(:class => 'unactive', :title => 'favorite').should == ' class="unactive" title="favorite"'
  end
  
  it "should generate a tag with attributes and content" do
    content_tag('p').should == '<p></p>'
    content_tag('p').should == '<p></p>'
    content_tag('p', 'Description').should == '<p>Description</p>'
    content_tag('p') { 'Description' }.should == '<p>Description</p>'
    content_tag('p', 'Description', :class => 'active').should == '<p class="active">Description</p>'
  end
  
  it "should generate a header for a RubyName with markup" do
    header_with_markup('', '::', 'Enumerable').should == '<span class="name">Enumerable</span>'
    header_with_markup('Module::SubModule', '#', 'method').should == '<span class="path">Module::SubModule</span><span>#</span><span class="name">method</span>'
  end
  
  extend HTMLHelpersHelper
  
  it "should render a description with the correct partial" do
    self.partials = {'class' => stub() }
    description = stub(:template_name => 'class')
    
    self.partials['class'].expects(:result)
    expects(:assign).with(:description, description)
    
    render_description(description)
  end
end