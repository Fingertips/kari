source_root = ENV['KARI_ENV'] != 'test' ? NSBundle.mainBundle.resourcePath.fileSystemRepresentation : File.expand_path('../../', __FILE__)
ENV['KARI_ENV']   ||= 'release'
ENV['STANDALONE'] ||= 'true'
ROOT_PATH = ENV['KARI_ROOT'] || source_root

framework 'Cocoa'
framework 'WebKit'

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

%w(lib app/helpers app/models app/views app/controllers).each do |subdir|
  $:.unshift("#{Kari.root_path}/#{subdir}")
  Dir.glob("#{Kari.root_path}/#{subdir}/*.{rb,rbo}").each do |file|
    library = File.basename(file, File.extname(file))
    require library
  end
end

if (ENV['STANDALONE'].to_s == 'true') and (Kari.env != 'test')
  NSApplicationMain(0, nil)
end