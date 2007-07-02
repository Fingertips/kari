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