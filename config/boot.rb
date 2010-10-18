framework 'Cocoa'

release = (ENV['RUCOLA_ENV'] != 'test')
ROOT = release ? NSBundle.mainBundle.resourcePath.fileSystemRepresentation : File.expand_path('../../', __FILE__)

if release
  frameworks = NSBundle.mainBundle.privateFrameworksPath.to_s
  if File.exist?(File.join(frameworks, 'MacRuby.framework'))
    $:.map! { |p| p.sub(%r{^/Library/Frameworks}, frameworks) }
  end
  
  Dir.glob(File.join(ROOT, '*.{rb,rbo}')).each do |file|
    file = File.basename(file, File.extname(file))
    require file unless file == 'boot'
  end
else
  $:.unshift(File.join(ROOT, 'lib'))
  $:.unshift(File.join(ROOT, 'app/models'))
  
  require 'class_tree_node'
  require 'fullname_search'
  require 'hash_tree'
end