# Load Rucola tasks
SOURCE_ROOT = File.dirname(__FILE__)
require 'rubygems'
require 'rucola/rucola_support'
load 'rucola/tasks/main.rake'

# Application configuration

# You only need to specify this if for some reason the applications name
# might be different than the one specified in the Info.plist file under key: CFBundleExecutable
#
# APPNAME = "Kari"
# TARGET  = "#{APPNAME}.app"

# You only need to specify this if for some reason the applications version
# might be different than the one specified in the Info.plist file under key: CFBundleVersion
#
# APPVERSION = INFO_PLIST['CFBundleShortVersionString']
# APPVERSION = "rev#{`svn info`[/Revision: (\d+)/, 1]}"
# APPVERSION = Time.now.strftime("%Y-%m-%d")

# require 'uri'

PUBLISH_URI = URI.parse('scp://eloy@updates.kari.fngtps.com/var/www/updates.kari/htdocs')
APPCAST_URI = PUBLISH_URI

# Tasks

desc 'Deploy a release build.'
task :deploy do
  puts "\nDeploying...\n\n"
  
  Rake::Task['release'].invoke
  Rake::Task['deploy:package'].invoke
  Rake::Task['deploy:sparkle_appcast'].invoke
  Rake::Task['deploy:release_notes'].invoke
  Rake::Task['deploy:upload'].invoke
  Rake::Task['xcode:clean'].invoke
  Rake::Task['dependencies:clean'].invoke
end

desc "Removes the preference and app support files."
task :clean_user_files do
  `rm ~/Library/Preferences/com.fngtps.Kari.plist`
  FileUtils.rm_rf(File.expand_path("~/Library/Application Support/Kari"))
end