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
end

desc "Run all specs"
task :spec => SPEC_DIRECTORIES.map { |s| "spec:#{s}" } do
end

task :default => :spec