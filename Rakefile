namespace :spec do
  task :autotest do
    require './spec/rspec_autotest'
    RspecAutotest.run
  end
end


namespace :build do
  task :all do
    `xcodebuild`
  end
end

task :run => :"build:all" do
  `build/Release/Kari.app/Contents/MacOS/Kari`
end

task :test do
  Dir['test/**/test_*.rb'].each do |file|
    ruby file
  end
end

task :clean do
  `rm ~/Library/Preferences/nl.fngtps.Kari.plist`
end