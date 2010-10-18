APP_NAME = 'Kari'

desc "Run all specs"
task :spec do
  sh "macbacon #{FileList['spec/**/*_spec.rb'].join(' ')}"
end

task :default => :spec