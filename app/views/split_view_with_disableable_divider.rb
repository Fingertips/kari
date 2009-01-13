class SplitViewWithDisableableDivider < NSSplitView
  attr_reader :disableDivider
  def disableDivider=(value)
    @disableDivider = value
    resetCursorRects
  end
  
  def mouseDown(event)
    super unless disableDivider
  end
  
  def resetCursorRects
    super unless disableDivider
  end
end