require 'osx/cocoa'

class PreferencesController < OSX::NSWindowController
  
  DEFAULT_BOOKMARKS = ['Object', 'String', 'Array', 'Hash', 'Numeric']
  def self.registerDefaults
    bookmarks = []
    DEFAULT_BOOKMARKS.each_with_index do |title, idx|
      bookmarks.push({:id => idx, :title => title, :url => "http://127.0.0.1:9999/show/#{title}", :order_index => idx})
    end
    OSX::NSUserDefaults.standardUserDefaults.registerDefaults({ 'RubyInstallation' => '/usr', 'Bookmarks' => bookmarks })
  end
  
  def self.synchronize
    OSX::NSUserDefaults.standardUserDefaults.synchronize
  end

  def init
    self if self.initWithWindowNibName('Preferences')
  end
  
  def awakeFromNib
  end
  
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
