framework 'Cocoa'

release = (ENV['RUCOLA_ENV'] != 'test')
ROOT_PATH = release ? NSBundle.mainBundle.resourcePath.fileSystemRepresentation : File.expand_path('../../', __FILE__)

module Kari
  def self.env
    ENV['RUCOLA_ENV']
  end
  
  def self.application_support_path
    File.expand_path('/Library/Application Support/Kari')
  end
  
  def self.root_path
    ROOT_PATH
  end
end

if release
  frameworks = NSBundle.mainBundle.privateFrameworksPath.to_s
  if File.exist?(File.join(frameworks, 'MacRuby.framework'))
    $:.map! { |p| p.sub(%r{^/Library/Frameworks}, frameworks) }
  end
  
  Dir.glob(File.join(ROOT_PATH, '*.{rb,rbo}')).each do |file|
    file = File.basename(file, File.extname(file))
    require file unless file == 'boot'
  end
else
  $:.unshift(File.join(ROOT_PATH, 'lib'))
  
  require 'core_ext'
  require 'search_kit'
  
  $:.unshift(File.join(ROOT_PATH, 'app/helpers'))
  
  require 'description_extensions'
  require 'flow_helpers'
  require 'html_helpers'
  
  $:.unshift(File.join(ROOT_PATH, 'app/models'))
  
  require 'class_tree_node'
  require 'fullname_search'
  require 'hash_tree'
  require 'karidoc_generator'
  require 'manager'
  
end

require 'tmpdir'