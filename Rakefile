require 'rake/testtask'

namespace :spec do
  task :autotest do
    require './spec/rspec_autotest'
    RspecAutotest.run
  end
end


namespace :build do
  task :all do
    puts '', 'COMPILING APP', ''
    `xcodebuild -configuration Release`
  end
  
  task :pre_bundle do
    `rm -rf build/Kari.build build/Release build/Standalone`
    puts '', 'UPDATING SVN CHECKOUT', ''
    puts `svn up`
  end
  
  desc "Builds a standalone Kari.app bundle."
  task :bundle => [:pre_bundle, :all] do
    standalone_dir = 'build/Standalone'
    `mkdir -p #{standalone_dir}`
    puts '', 'CREATING STANDALONE APP BUNDLE', ''
    svn_rev = `svn info`.scan(/Revision:\s(\d+)/)[0][0]
    puts `ruby /Library/Frameworks/RubyCocoa.framework/Versions/Current/Tools/standaloneify.rb -d "#{standalone_dir}/Kari r#{svn_rev}.app" "build/Release/Kari.app"`
    `open #{standalone_dir}`
  end
end

task :run => :"build:all" do
  `build/Release/Kari.app/Contents/MacOS/Kari`
end

task :default => :run

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
  `rm ~/Library/Preferences/com.fngtps.Kari.plist`
end
