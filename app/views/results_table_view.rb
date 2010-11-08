class ResultsTableView < NSTableView
  def _highlightColorForCell(cell)
    NSColor.secondarySelectedControlColor
  end
    
  def control(control, textView:textView, doCommandBySelector:commandSelector)
    case commandSelector.to_s
    when 'moveUp:'
      scrollToRow(selectedRow - 1)
    when 'moveDown:'
      scrollToRow(selectedRow + 1)
    when 'insertNewline:'
      target.rowDoubleClicked(self) if !numberOfRows.zero?
    else
      return false
    end; true
  end
  
  def scrollToRow(row, select = true)
    unless row < 0 or row == numberOfRows
      selectRowIndexes(NSIndexSet.indexSetWithIndex(row), byExtendingSelection:false) if select
      scrollRowToVisible(row)
    end
  end
end