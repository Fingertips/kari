class SearchField < OSX::NSSearchField
  attr_accessor :keyDelegate
  
  def textView_doCommandBySelector(textView, selector)
    #p selector
    if %w(moveUp: moveDown: insertNewline:).include? selector
      @keyDelegate.tryToPerform_with(selector, textView)
    else
      tryToPerform_with(selector, textView)
    end
  end
end