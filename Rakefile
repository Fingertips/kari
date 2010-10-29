APP_NAME         = 'Kari'
SPEC_DIRECTORIES = %w(helpers models lib)

namespace :spec do
  SPEC_DIRECTORIES.each do |part|
    desc "Run all specs in the #{part} directory"
    task part do
      specs = FileList["spec/#{part}**/*_spec.rb"]
      sh "macbacon #{specs.join(' ')}"
    end
  end
  
  desc "Run all specs one by one to isolate crashes"
  task :one_by_one do
    filelist = []
    
    SPEC_DIRECTORIES.each do |part|
      filelist.concat FileList["spec/#{part}**/*_spec.rb"]
    end
    
    filelist.each do |filename|
      sh "macbacon #{filename}"
    end
  end
end

desc "Run all specs"
task :spec => SPEC_DIRECTORIES.map { |s| "spec:#{s}" } do
end

task :default => :spec