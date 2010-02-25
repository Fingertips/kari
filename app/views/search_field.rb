class SearchField < OSX::NSSearchField
  FORWARD_SELECTORS = %w(moveUp: moveDown: insertNewline:)
  
  attr_accessor :keyDelegate
  
  def textView_doCommandBySelector(textView, selector)
    if @keyDelegate.wantsForwardedKeyEvents? and FORWARD_SELECTORS.include?(selector)
      @keyDelegate.tryToPerform_with(selector, textView)
    else
      tryToPerform_with(selector, textView)
    end
  end
end