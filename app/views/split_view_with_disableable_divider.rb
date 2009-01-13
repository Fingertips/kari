class SplitViewWithDisableableDivider < NSSplitView
  attr_reader :disableDivider
  
  def disableDivider=(disabled)
    @disableDivider = disabled
    resetCursorRects
  end
  
  def mouseDown(event)
    super unless disableDivider
  end
  
  def resetCursorRects
    super unless disableDivider
  end
end