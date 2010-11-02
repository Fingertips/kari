class PreferencesController < NSController
  def browseForRubyInstallation(sender)
    openDirectoryPanel = NSOpenPanel.openPanel
    openDirectoryPanel.canChooseDirectories = true
    openDirectoryPanel.canChooseFiles = false
    openDirectoryPanel.allowsMultipleSelection = false
    openDirectoryPanel.showsHiddenFiles = true # undocumented API
    
    buttonClicked = openDirectoryPanel.runModal
    if buttonClicked == NSOKButton
      path = openDirectoryPanel.filenames.objectAtIndex(0).to_s
      NSUserDefaults.standardUserDefaults.setObject_(path, forKey: 'RubyInstallation')
    end
  end
end