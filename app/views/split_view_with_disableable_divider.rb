class SplitViewWithDisableableDivider < NSSplitView
  attr_reader :disableDivider
  
  def disableDivider=(value)
    @disableDivider = value
    resetCursorRects
  end
  
  alias_method :_mouseDown, :mouseDown
  def mouseDown(event)
    _mouseDown(event) unless disableDivider
  end
  
  alias_method :_resetCursorRects, :resetCursorRects
  def resetCursorRects
    _resetCursorRects unless disableDivider
  end
end