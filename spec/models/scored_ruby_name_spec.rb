require File.expand_path('../../spec_helper', __FILE__)

module ScoredRubyNameHelper
  def _display_name_at_position(string, position)
    attributes = string.attributesAtIndex(position, effectiveRange: nil)
    if font = attributes[NSFontAttributeName]
      font.displayName
    end
  end
  
  def assert_normal(string, position)
    _display_name_at_position(string, position).should == 'Lucida Grande'
  end
  
  def assert_bold(string, position)
    _display_name_at_position(string, position).should == 'Lucida Grande Bold'
  end
end

describe "ScoredRubyName" do
  extend ScoredRubyNameHelper
  
  it "should instantiate with name, karidocFilename, and query" do
    name = ScoredRubyName.alloc.initWithName("ActiveRecord::Base", karidocFilename: '/path/to/karidoc', query: 'ast')
    name.name.should == 'ActiveRecord::Base'
    name.karidocFilename.should == '/path/to/karidoc'
    name.query.should == 'ast'
  end
  
  it "should compute a score for the match between the name and the query" do
    name = ScoredRubyName.alloc.initWithName("ActiveSupport::Multibyte::Chars::new", karidocFilename: '', query: nil)
    name.score.should == 0
    
    [
      ['active', 36],
      ['Active', 36],
      ['actch', 13],
      ['tiVE', 16],
      ['acch', 8],
      ['acmp', 5]
    ].each do |example, expected|
      name.query = example
      name.score.should == expected
    end
    
    name = ScoredRubyName.alloc.initWithName("Needle::InterceptorChainBuilder::ProxyObjectChainElement#process_next", karidocFilename: '', query: nil)
    name.score.should == 0
    
    [
      ['actcha', 26]
    ].each do |example, expected|
      name.query = example
      name.score.should == expected
    end    
  end
  
  it "should return the name marked with its match" do
    name = ScoredRubyName.alloc.initWithName("ActiveRecord::Base", karidocFilename: '', query: 'ase')
    markedString = name.nameWithMarkup
    markedString.string.should == "ActiveRecord::Base"
    
    assert_bold(markedString, 0)
    assert_normal(markedString, 1)
    assert_normal(markedString, 10)
    assert_bold(markedString, 16)
    assert_bold(markedString, 17)
  end
end