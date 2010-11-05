require File.expand_path('../../spec_helper', __FILE__)

describe "SearchField" do
  before do
    @search_field = SearchField.alloc.init
    @keyDelegate = mock('Key Delegate')
    @search_field.keyDelegate = @keyDelegate
  end
  
  it "should forward specified key events to the keyDelegate" do
    @keyDelegate.stubs(:wantsForwardedKeyEvents?).returns(true)
    SearchField::FORWARD_SELECTORS.each do |key|
      @keyDelegate.expects(:tryToPerform).with(key, with: nil)
      @search_field.textView(nil, doCommandBySelector:key)
    end
  end
  
  it "should not forward other key events to the keyDelegate" do
    @keyDelegate.stubs(:wantsForwardedKeyEvents?).returns(true)
    %w(does: not: exist:).each do |key|
      @keyDelegate.expects(key.to_sym).with(key, nil).times(0)
      @search_field.textView(nil, doCommandBySelector:key)
    end
  end
  
  # DISABLED: Mocha doesn't register the call although it is sent
  # it "should only forward key events to the keyDelegate if the keyDelegate wants it" do
  #   @keyDelegate.stubs(:wantsForwardedKeyEvents?).returns(false)
  #   @search_field.expects(:tryToPerform).with('insertNewline:', with: nil)
  #   @search_field.textView_doCommandBySelector(nil, 'insertNewline:')
  # end
end