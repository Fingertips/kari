class ResultsTableView < NSTableView
  def _highlightColorForCell(cell)
    NSColor.secondarySelectedControlColor
  end
    
  def acceptsFirstResponder
    false
  end
  
  def control(control, textView:textView, doCommandBySelector:commandSelector)
    case commandSelector
    when :moveUp
      scrollToRow(selectedRow - 1)
    when :moveDown
      scrollToRow(selectedRow + 1)
    when :insertNewline
      target.rowDoubleClicked(self) if !numberOfRows.zero?
    end
  end
  
  def scrollToRow(row, select = true)
    unless row < 0 or row == numberOfRows
      selectColumnIndexes(NSIndexSet.indexSetWithIndex(row), byExtendingSelection:false) if select
      scrollRowToVisible(row)
    end
  end
end