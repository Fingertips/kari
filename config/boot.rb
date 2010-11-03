framework 'Cocoa'
framework 'WebKit'

release = (ENV['KARI_ENV'] != 'test')
ROOT_PATH = ENV['KARI_ROOT'] || (release ? NSBundle.mainBundle.resourcePath.fileSystemRepresentation : File.expand_path('../../', __FILE__))

module Kari
  def self.env
    ENV['KARI_ENV']
  end

  def self.application_support_path
    File.expand_path('~/Library/Application Support/Kari')
  end

  def self.root_path
    ROOT_PATH
  end

  def self.assets_path
    File.join(root_path, 'app/assets')
  end
end

require 'tmpdir'

frameworks = NSBundle.mainBundle.privateFrameworksPath.to_s
if File.exist?(File.join(frameworks, 'MacRuby.framework'))
  $:.map! { |p| p.sub(%r{^/Library/Frameworks}, frameworks) }
end

%w(lib app/helpers app/models app/views app/controllers).each do |subdir|
  $:.unshift("#{Kari.root_path}/#{subdir}")
  Dir.glob("#{Kari.root_path}/#{subdir}/*.{rb,rbo}").each do |file|
    library = File.basename(file, File.extname(file))
    require library
  end
end

ToolbarController.alloc.init

unless Kari.env == 'test'
  NSApplicationMain(0, nil)
end