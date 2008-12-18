class ApplicationController < Rucola::RCController
  STATUS_BAR_HEIGHT = 20
  
  def topViewOfSplitView
    @topViewOfSplitView ||= @splitView.subviews.first
  end
  
  def bottomViewOfSplitView
    @bottomViewOfSplitView ||= @splitView.subviews.last
  end
  
  def toggleClassBrowser(toggle_button)
    will_animate_splitView do
      splitView_frame, top_frame, bottom_frame = calculate_splitView_frames
      splitView_animation = { OSX::NSViewAnimationTargetKey => @splitView, OSX::NSViewAnimationEndFrameKey => OSX::NSValue.valueWithRect(splitView_frame) }
      
      # If the class browser is _not_ visible, so we are going to make it dissapear,
      # then we shouldn't animate the bottom view. The reason being that if can become
      # ugly if the bottom view shrinks faster than the total split view.
      # Ie: You will see a empty piece of frame for a split second.
      # To fix this we simply set the complete frame without animating,
      # so it will actually appear from under the status bar.
      #
      # However, if we are going to show the class browser we should animate,
      # otherwise the same problem as before will occur (seeing an empty piece of frame for a moment).
      # if class_browser_visible?
        bottomView_animation = { OSX::NSViewAnimationTargetKey => bottomViewOfSplitView, OSX::NSViewAnimationEndFrameKey => OSX::NSValue.valueWithRect(bottom_frame) }
        animate(splitView_animation, bottomView_animation)
      # else
      #   bottomViewOfSplitView.frame = bottom_frame
      #   animate(splitView_animation)
      # end
    end
  end
  
  def splitView_resizeSubviewsWithOldSize(splitView, old_size)
    return if updating_splitView?
    
    will_update_splitView do
      splitView_frame, top_frame, bottom_frame = calculate_splitView_frames
      @splitView.frame = splitView_frame
      topViewOfSplitView.frame = top_frame
      bottomViewOfSplitView.frame = bottom_frame
    end
  end
  
  def setup_splitView!
    splitView_resizeSubviewsWithOldSize(nil, nil)
  end
  
  def splitViewDidResizeSubviews(notification)
    return if animating_splitView?
    
    if updating_splitView?
      done_updating_splitView!
    else
      # Since the class browser fits to the top frame, and the top frame returns the correct
      # height whereas the browser does not for some reason, we actually store the height of the top frame.
      self.class_browser_height = topViewOfSplitView.frame.height
    end
  end
  
  def class_browser_height=(height)
    preferences['ClassBrowserHeight'] = height
    @class_browser_height = height
  end
  
  def class_browser_height
    @class_browser_height ||= ((preferences['ClassBrowserHeight'].to_i if preferences['ClassBrowserHeight']) || 135) # should become a default pref
  end
  
  private
  
  def preferences
    OSX::NSUserDefaults.standardUserDefaults
  end
  
  def class_browser_visible?
    preferences['ClassBrowserVisible'].to_ruby
  end
  
  def updating_splitView?
    @updating_splitView
  end
  
  def done_updating_splitView!
    @updating_splitView = false
  end
  
  def will_update_splitView
    @updating_splitView = true
    yield
  end
  
  def animating_splitView?
    @animating_splitView
  end
  
  def will_animate_splitView(&block)
    @animating_splitView = true
    will_update_splitView(&block)
    done_updating_splitView!
    @animating_splitView = false
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
  
  def calculate_splitView_frames
    splitView_frame = @splitView.frame
    top_frame = topViewOfSplitView.frame
    bottom_frame = bottomViewOfSplitView.frame
    
    top_frame.height = class_browser_height
    top_frame.width = bottom_frame.width = splitView_frame.width
    bottom_frame.y = top_frame.height + @splitView.dividerThickness
    
    if class_browser_visible?
      splitView_frame.height = contentView_minus_statusBar_frame.height
      bottom_frame.height = splitView_frame.height - top_frame.height - @splitView.dividerThickness
    else
      bottom_frame.height = contentView_minus_statusBar_frame.height
      splitView_frame.height = top_frame.height + @splitView.dividerThickness + bottom_frame.height
    end
    
    [splitView_frame, top_frame, bottom_frame]
  end
end