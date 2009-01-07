class PreferencesController < Rucola::RCWindowController
  DEFAULT_BOOKMARKS = ['Object', 'String', 'Array', 'Hash', 'Numeric']
  
  class << self
    def preferences
      NSUserDefaults.standardUserDefaults
    end
    
    def registerDefaults
      # FIXME: For now disabled the default bookmarks because I need to think about how we can
      # provide links to some default Classes if we don't know yet where the files will be stored.
      # Maybe this should be set when running for the first time??
      #
      # bookmarks = []
      # DEFAULT_BOOKMARKS.each_with_index do |title, idx|
      #   bookmarks.push({:id => idx, :title => title, :url => "http://127.0.0.1:10002/show/#{title}", :order_index => idx})
      # end
      # preferences.registerDefaults({ 'RubyInstallation' => '/usr', 'Bookmarks' => bookmarks })
      
      preferences.registerDefaults({ 'RubyInstallation' => '/usr', 'Bookmarks' => [] })
    end
    
    def synchronize
      preferences.synchronize
    end
  end
  
  def browseForRubyInstallation(sender)
    openDirectoryPanel = NSOpenPanel.openPanel
    openDirectoryPanel.canChooseDirectories = true
    openDirectoryPanel.canChooseFiles = false
    openDirectoryPanel.allowsMultipleSelection = false
    openDirectoryPanel.showsHiddenFiles = true # undocumented API
    
    buttonClicked = openDirectoryPanel.runModal
    if buttonClicked == NSOKButton
      path = openDirectoryPanel.filenames.objectAtIndex(0).to_s
      NSUserDefaults.standardUserDefaults.setObject_forKey(path, 'RubyInstallation')
    end
  end
end