require File.expand_path('../../test_helper', __FILE__)

describe "ScoredRubyName" do
  it "should instantiate with name, karidocFilename, and query" do
    name = OSX::ScoredRubyName.alloc.initWithName_karidocFilename_query("ActiveRecord::Base", '/path/to/karidoc', 'ast')
    name.name.should == 'ActiveRecord::Base'
    name.karidocFilename.should == '/path/to/karidoc'
    name.query.should == 'ast'
  end
  
  it "should compute a score for the match between the name and the query" do
    name = OSX::ScoredRubyName.alloc.initWithName_karidocFilename_query("ActiveRecord::Base", '', nil)
    name.score.should == 0
    
    [
      ['active', 6],
      ['Active', 6],
      ['baSe', 4],
      ['acba', 4],
      ['baac', 2]
    ].each do |example, expected|
      name.query = example
      name.score.should == expected
    end
  end
  
  it "should return the name marked with its match" do
    name = OSX::ScoredRubyName.alloc.initWithName_karidocFilename_query("ActiveRecord::Base", '', 'ase')
    markedString = name.nameWithMarkup
    markedString.string.should == "ActiveRecord::Base"
    
    assert_bold(markedString, 0)
    assert_normal(markedString, 1)
    assert_normal(markedString, 10)
    assert_bold(markedString, 16)
    assert_bold(markedString, 17)
  end
  
  private
  
  def _display_name_at_position(string, position)
    attributes = string.attributesAtIndex_effectiveRange(position, nil)
    if font = attributes[OSX::NSFontAttributeName]
      font.displayName
    end
  end
  
  def assert_normal(string, position)
    assert_equal 'Baskerville', _display_name_at_position(string, position)
  end
  
  def assert_bold(string, position)
    assert_equal 'Baskerville Bold', _display_name_at_position(string, position)
  end
end