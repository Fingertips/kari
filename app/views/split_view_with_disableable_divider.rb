class SplitViewWithDisableableDivider < NSSplitView
  attr_reader :disableDivider
  
  def disableDivider=(value)
    @disableDivider = value
    resetCursorRects
  end
  
  def mouseDown(event)
    super_mouseDown(event) unless disableDivider
  end
  
  def resetCursorRects
    super_resetCursorRects unless disableDivider
  end
end