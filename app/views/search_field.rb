class SearchField < NSSearchField
  FORWARD_SELECTORS = %w(moveUp: moveDown: insertNewline:)
  
  attr_accessor :keyDelegate
  
  def textView_doCommandBySelector(textView, selector)
    if @keyDelegate.wantsForwardedKeyEvents? and FORWARD_SELECTORS.include?(selector)
      @keyDelegate.tryToPerform(selector, with: textView)
    else
      tryToPerform(selector, with: textView)
    end
  end
end