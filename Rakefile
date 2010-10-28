APP_NAME = 'Kari'

desc "Run all specs"
task :spec do
  %w(helpers models lib).each do |part|
    specs = FileList["spec/#{part}**/*_spec.rb"]
    sh "macbacon #{specs.join(' ')}"
  end
end

task :default => :spec