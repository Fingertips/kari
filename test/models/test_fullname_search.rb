require File.expand_path('../../test_helper', __FILE__)

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
  end
  
  it "should match fullnames" do
    FullnameSearch.match('nothing', 'ActiveRecord::Base').should == false
    FullnameSearch.match('actba', 'ActiveRecord::Base').should == ['ActiveRecord::Base', "<strong>Act</strong>iveRecord::<strong>Ba</strong>se"]
  end
end