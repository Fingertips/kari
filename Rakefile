# Load Rucola tasks
SOURCE_ROOT = File.dirname(__FILE__)
require 'rubygems'
require 'rucola/rucola_support'
load 'rucola/tasks/main.rake'

# Load default tasks
require 'rake/rdoctask'

# Application configuration

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

namespace :defaults do
  desc 'Show the applications preferences.'
  task :show do
    puts `/usr/bin/defaults read #{INFO_PLIST['CFBundleIdentifier']}`
  end
  
  desc 'Open the applications preferences.'
  task :open do
    file = File.expand_path("~/Library/Preferences/#{INFO_PLIST['CFBundleIdentifier']}.plist")
    `open '#{file}'`
  end
end

namespace :documentation do
  Rake::RDocTask.new(:generate) do |rdoc|
    rdoc.title = 'Kari'
    rdoc.rdoc_dir = 'documentation'
    rdoc.rdoc_files.include("app/**/*.rb", "lib/**/*.rb")
    rdoc.options << "--all" << "--charset" << "utf-8"
  end
end