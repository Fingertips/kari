class ApplicationController < Rucola::RCController
  STATUS_BAR_HEIGHT = 20
  
  def setup_toggleClassBrowserVisbilityButton_state!
    p @splitView.frame
    p contentView_minus_statusBar_frame
    @toggleClassBrowserVisbilityButton.state = (contentView_minus_statusBar_frame == @splitView.frame ? OSX::NSOnState : OSX::NSOffState)
  end
  
  def topViewOfSplitView
    @topViewOfSplitView ||= @splitView.subviews.first
  end
  
  def bottomViewOfSplitView
    @bottomViewOfSplitView ||= @splitView.subviews.last
  end
  
  def toggleClassBrowser(toggle_button)
    #OSX::NSUserDefaults.standardUserDefaults['ClassBrowserVisible'] = toggle_button.state
    
    if toggle_button.state == OSX::NSOnState
      splitView_frame = contentView_minus_statusBar_frame
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
      
      p [top_frame, bottom_frame]
      p new_frame
      p top_frame.height + bottom_frame.height + @splitView.dividerThickness
      
      topViewOfSplitView.frame, bottomViewOfSplitView.frame = top_frame, bottom_frame
    end
  end
  
  def setup_splitView!
    # p class_browser_height
    # p @splitView.frame
    # new_frame = contentView_minus_statusBar_frame
    # new_frame.height += class_browser_height + @splitView.dividerThickness
    # p new_frame
    # @splitView.frame = new_frame
    # p @splitView.frame
    # splitView_resizeSubviewsWithOldSize(nil, nil)
  end
  
  def will_update_split_view
    @will_update_split_view = true
    yield
  end
  
  def splitViewDidResizeSubviews(notification)
    if @will_update_split_view
      @will_update_split_view = false
    else
      self.class_browser_height = @classBrowser.frame.height
    end
  end
  
  def class_browser_height=(height)
    preferences['ClassBrowserHeight'] = height
    @class_browser_height = height
  end
  
  # test
  def class_browser_height
    @class_browser_height || (preferences['ClassBrowserHeight'].to_i if preferences['ClassBrowserHeight']) || 157
  end
  
  private
  
  def preferences
    OSX::NSUserDefaults.standardUserDefaults
  end
  
  def contentView_minus_statusBar_frame
    frame = @window.contentView.frame.dup
    frame.height -= STATUS_BAR_HEIGHT
    frame.y += STATUS_BAR_HEIGHT
    frame
  end
  
  def animate(*view_animations)
    animation = OSX::NSViewAnimation.alloc.initWithViewAnimations(view_animations)
    animation.animationBlockingMode = OSX::NSAnimationBlocking
    animation.duration = 0.3
    animation.startAnimation
  end
end