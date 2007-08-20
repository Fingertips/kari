require 'rake/testtask'

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

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/test_*.rb']
  t.verbose = true
end

task :bench do
  Dir['bench/**/bench_*.rb'].each do |file|
    ruby file
  end  
end

task :clean do
  `rm ~/Library/Preferences/nl.fngtps.Kari.plist`
end
