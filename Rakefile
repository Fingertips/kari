APP_NAME         = 'Kari'
SPEC_DIRECTORIES = %w(helpers models lib views controllers)

namespace :spec do
  SPEC_DIRECTORIES.each do |part|
    desc "Run all specs in the #{part} directory"
    task part do
      specs = FileList["spec/#{part}**/*_spec.rb"]
      sh "macruby #{specs.join(' ')}"
    end
  end
  
  desc "Run all specs one by one to isolate crashes"
  task :one_by_one do
    filelist = []
    
    SPEC_DIRECTORIES.each do |part|
      filelist.concat FileList["spec/#{part}**/*_spec.rb"]
    end
    
    filelist.each do |filename|
      sh "macruby #{filename}"
    end
  end
end

desc "Run all specs"
task :spec => SPEC_DIRECTORIES.map { |s| "spec:#{s}" } do
end

desc "Compile the app"
task :compile do
  sh "xcodebuild -configuration Debug"
end

desc "Clean the compiled app"
task :clean do
  sh "rm -Rf #{File.expand_path('../build', __FILE__)}"
end

desc "Run the app"
task :run => [:clean, :compile] do
  sh "env KARI_ENV=debug open #{File.expand_path("../build/Debug/Kari.app", __FILE__)}"
end

task :default => :run