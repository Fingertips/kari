# Application configuration
APPNAME               = "Kari"
TARGET                = "#{APPNAME}.app"
#APPVERSION           = "rev#{`svn info`[/Revision: (\d+)/, 1]}"
APPVERSION            = Time.now.strftime("%Y-%m-%d")
PUBLISH               = 'yourname@yourhost:path'

# Load Rucola tasks
SOURCE_ROOT = File.dirname(__FILE__)
require 'rubygems'
require 'rucola/rucola_support'
load 'rucola/tasks/main.rake'

desc "Removes the preference and app support files."
task :clean_user_files do
  `rm ~/Library/Preferences/com.fngtps.Kari.plist`
  FileUtils.rm_rf(File.expand_path("~/Library/Application Support/Kari"))
end
