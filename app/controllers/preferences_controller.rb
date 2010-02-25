class PreferencesController < Rucola::RCWindowController
  def browseForRubyInstallation(sender)
    openDirectoryPanel = OSX::NSOpenPanel.openPanel
    openDirectoryPanel.canChooseDirectories = true
    openDirectoryPanel.canChooseFiles = false
    openDirectoryPanel.allowsMultipleSelection = false
    openDirectoryPanel.showsHiddenFiles = true # undocumented API
    
    buttonClicked = openDirectoryPanel.runModal
    if buttonClicked == OSX::NSOKButton
      path = openDirectoryPanel.filenames.objectAtIndex(0).to_s
      OSX::NSUserDefaults.standardUserDefaults.setObject_forKey(path, 'RubyInstallation')
    end
  end
end