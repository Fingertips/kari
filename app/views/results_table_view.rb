class ResultsTableView < NSTableView
  def awakeFromNib
    self.rowHeight = 24
    setIntercellSpacing(NSSize.new(0.0, 3.0))
    tableColumns.first.dataCell = ResultCell.alloc.init
  end
  
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
    target.performSelector_withObject(doubleAction, self) if !numberOfRows.zero? and target.respondsToSelector(doubleAction)
  end
  
  def moveUp(sender)
    scrollToRow(selectedRow - 1)
  end
  
  def moveDown(sender)
    scrollToRow(selectedRow + 1)
  end
  
  private
  
  def scrollToRow(row, select = true)
    unless row < 0 or row == numberOfRows
      selectRow_byExtendingSelection(row, false) if select
      scrollRowToVisible(row)
    end
  end
end

class ResultCell < NSCell
  LEFT_MARGIN = 10
  
  def drawInteriorWithFrame_inView(frame, view)
    attributes = { NSFontAttributeName => NSFont.fontWithName_size('Baskerville', 16) }
    
    objectValue.drawAtPoint_withAttributes(
      NSMakePoint(frame.origin.x + LEFT_MARGIN, frame.origin.y - 2),
      attributes
    )
  end
  
  def drawsBackground
    false
  end
end