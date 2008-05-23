require File.expand_path('../../test_helper', __FILE__)

describe "SearchField" do
  tests SearchField
  alias_method :search_field, :instance_to_be_tested
  
  def after_setup
    @keyDelegate = mock('Key Delegate')
    assigns(:keyDelegate, @keyDelegate)
    @keyDelegate.stubs(:wantsForwardedKeyEvents?).returns(true)
  end
  
  it "should forward specified key events to the keyDelegate" do
    SearchField::FORWARD_SELECTORS.each do |key|
      @keyDelegate.expects(:tryToPerform_with).with(key, nil)
      search_field.textView_doCommandBySelector(nil, key)
    end
  end
  
  it "should not forward other key events to the keyDelegate" do
    %w(does: not: exist:).each do |key|
      @keyDelegate.expects(key.to_sym).with(key, nil).times(0)
      search_field.textView_doCommandBySelector(nil, key)
    end
  end
  
  it "should only forward key events to the keyDelegate if the keyDelegate wants it" do
    @keyDelegate.stubs(:wantsForwardedKeyEvents?).returns(false)
    
    search_field.expects(:tryToPerform_with).with('insertNewline:', nil)
    search_field.textView_doCommandBySelector(nil, 'insertNewline:')
  end
end