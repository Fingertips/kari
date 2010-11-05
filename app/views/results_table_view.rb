class ResultsTableView < NSTableView
  def _highlightColorForCell(cell)
    NSColor.secondarySelectedControlColor
  end
  
  def acceptsFirstResponder
    false
  end
  
  def wantsForwardedKeyEvents?
    !superview.superview.hidden?
  end
  
  # handlers for keys that are being pressed in the search field
  
  def insertNewline(sender)
    target.rowDoubleClicked(self) if !numberOfRows.zero?
  end
  
  def moveUp(sender)
    scrollToRow(selectedRow - 1)
  end
  
  def moveDown(sender)
    scrollToRow(selectedRow + 1)
  end
  
  def scrollToRow(row, select = true)
    unless row < 0 or row == numberOfRows
      selectColumnIndexes(NSIndexSet.indexSetWithIndex(row), byExtendingSelection:false) if select
      scrollRowToVisible(row)
    end
  end
end