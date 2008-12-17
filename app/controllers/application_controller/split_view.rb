class ApplicationController < Rucola::RCController
  STATUS_BAR_HEIGHT = 20
  
  def topViewOfSplitView
    @topViewOfSplitView ||= @splitView.subviews.first
  end
  
  def bottomViewOfSplitView
    @bottomViewOfSplitView ||= @splitView.subviews.last
  end
  
  def toggleClassBrowser(toggle_button)
    if toggle_button.state == OSX::NSOnState
      splitView_frame = @window.contentView.frame.dup
      splitView_frame.height -= STATUS_BAR_HEIGHT
      splitView_frame.y += STATUS_BAR_HEIGHT
    else
      splitView_frame = @splitView.frame.dup
      splitView_frame.height += (topViewOfSplitView.frame.height + @splitView.dividerThickness)
    end
    
    splitView_animation = { OSX::NSViewAnimationTargetKey => @splitView, OSX::NSViewAnimationEndFrameKey => OSX::NSValue.valueWithRect(splitView_frame) }
    animate(splitView_animation)
  end
  
  def splitView_resizeSubviewsWithOldSize(splitView, old_size)
    will_update_split_view do
      new_frame = @splitView.frame
      top_frame = topViewOfSplitView.frame
      bottom_frame = bottomViewOfSplitView.frame
      
      # The NSBrowser instance has a height of 135px in Interface Builder,
      # but for some reason it's 157px when I query it: @classBrowser.frame.height
      top_frame.height = class_browser_height - (2 * @splitView.dividerThickness) - 4
      top_frame.width = new_frame.width
      
      bottom_frame.y = top_frame.height + @splitView.dividerThickness
      bottom_frame.height = new_frame.height - top_frame.height
      bottom_frame.width = new_frame.width
      
      # p [top_frame, bottom_frame]
      # p new_frame
      # p top_frame.height + bottom_frame.height + @splitView.dividerThickness
      
      topViewOfSplitView.frame, bottomViewOfSplitView.frame = top_frame, bottom_frame
    end
  end
  
  def setup_splitView!
    splitView_resizeSubviewsWithOldSize(nil, nil)
  end
  
  def will_update_split_view
    @will_update_split_view = true
    yield
  end
  
  def splitViewDidResizeSubviews(notification)
    if @will_update_split_view
      @will_update_split_view = false
    else
      @class_browser_height = @classBrowser.frame.height
    end
  end
  
  def class_browser_height
    #@class_browser_height ||= @classBrowser.frame.height
    @class_browser_height || 157
  end
  
  private
  
  def animate(*view_animations)
    animation = OSX::NSViewAnimation.alloc.initWithViewAnimations(view_animations)
    animation.animationBlockingMode = OSX::NSAnimationBlocking
    animation.duration = 0.3
    animation.startAnimation
  end
end