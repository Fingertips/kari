require File.expand_path('../../spec_helper', __FILE__)

describe "FullnameSearch" do
  DESCRIPTIONS = {
    'ActiveRecord::Base' => '',
    'Binding' => '',
    'ActiveRecord::Associations' => '',
    'Integer' => ''
  }
  
  it "should find matches in simple arrays" do
    FullnameSearch.search('actba', DESCRIPTIONS).should == [
      ['ActiveRecord::Base', "<strong>Act</strong>iveRecord::<strong>Ba</strong>se"]
    ]
    FullnameSearch.search('ier', DESCRIPTIONS).should == [
      ['ActiveRecord::Associations', 'Act<strong>i</strong>v<strong>eR</strong>ecord::Associations'],
      ['ActiveRecord::Base', 'Act<strong>i</strong>v<strong>eR</strong>ecord::Base'],
      ['Integer', '<strong>I</strong>nt<strong>e</strong>ge']
    ]
  end
  
  it "should order matches by alphabetic order" do
    FullnameSearch.search('a', DESCRIPTIONS).should == [
      ['ActiveRecord::Associations', "<strong>A</strong>ctiveRecord::Associations"],
      ['ActiveRecord::Base', "<strong>A</strong>ctiveRecord::Base"]
    ]
  end
  
  it "should match fullnames" do
    FullnameSearch.match('nothing', 'ActiveRecord::Base').should == false
    FullnameSearch.match('actba', 'ActiveRecord::Base').should == ['ActiveRecord::Base', "<strong>Act</strong>iveRecord::<strong>Ba</strong>se"]
  end
end