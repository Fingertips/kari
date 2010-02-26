require 'yaml'
require 'fileutils'
require 'rdoc/ri/ri_descriptions'
require 'rdoc/markup/simple_markup/to_flow'

# Include some extentions to RI::Description so it's easier to work with the information
module RI
  class Description
    include DescriptionExtensions
  end
end

# Alias some classes and modules for newer versions of RDoc RI YAML files
module RDoc
  module RI; include ::RI; end
  module Markup; include ::SM; end
end

# Class that generates Karidoc files from the RI description
class KaridocGenerator
  ASSETS = %w(karidoc.css karidoc.js jquery-1.2.6.min.js)
  
  attr_accessor :karidoc_path, :description_files
  
  def initialize(karidoc_path, *description_files)
    self.karidoc_path      = karidoc_path
    self.description_files = description_files.flatten
  end
  
  def generate
    descriptions = description_files.map do |file|
      begin
        description = YAML.load_file(file)
        description.filename = file
        description
      rescue Errno::ENOENT => e
        log.debug("Couldn't load YAML file with path `#{file}' (#{e.message})")
      rescue TypeError => e
        log.debug("Couldn't parse YAML file with path `#{file}' (#{e.message})")
      rescue NoMethodError => e
        log.debug("Couldn't use description for the YAML file with path `#{file}' (#{e.message});")
        log.debug("- #{description.inspect}")
      end
    end.compact
    
    unless descriptions.empty?
      full_name = descriptions.first.full_name
      karidoc_filename = RubyName.karidoc_filename(karidoc_path, full_name)
      
      karidoc_path = compute_relative_path_from_root(karidoc_filename)
      FileUtils.mkdir_p(File.dirname(karidoc_filename))
      File.open(karidoc_filename, 'w') do |file|
        file.write(render(descriptions, :relative_path_to_root => self.class.compute_relative_path_to_root(karidoc_path)))
      end
      karidoc_path
    end
  end
  
  def render(descriptions, options={})
    raise ArgumentError, "Please specify :relative_path_to_root in the option hash." if options[:relative_path_to_root].nil?
    
    template_path = File.join(Rucola::RCApp.root_path, 'app', 'views', 'karidoc')
    template_file = File.join(template_path, 'layout.erb')
    
    partials = ['method', 'class', 'module'].inject({}) do |partials, t|
      partials[t] = self.class.template(File.join(template_path, "#{t}.erb")); partials
    end
    
    unless options[:relative_path_to_root].empty?
      relative_path = "#{options[:relative_path_to_root]}/KaridocAssets/"
    else
      relative_path = "KaridocAssets/"
    end
    
    namespace = Namespace.new({
      :descriptions        => descriptions,
      :full_name           => descriptions.first.full_name,
      :template_path       => template_path,
      :partials            => partials,
      :stylesheet          => "#{relative_path}karidoc.css",
      :javascripts         => [
        "#{relative_path}jquery-1.2.6.min.js",
        "#{relative_path}karidoc.js"
      ]
    })
    namespace.extend HTMLHelpers
    namespace.extend FlowHelpers
    
    self.class.template(template_file).result(namespace.binding)
  end
  
  def compute_relative_path_from_root(filename)
    self.class.compute_relative_path_from_root(karidoc_path, filename)
  end
  
  def karidoc_asset_path
    File.join(karidoc_path, 'KaridocAssets')
  end
  
  def freeze_assets
    FileUtils.mkdir_p(karidoc_asset_path)
    ASSETS.each do |asset|
      FileUtils.cp(File.join(Rucola::RCApp.root_path, 'app', 'assets', asset), File.join(karidoc_asset_path, asset))
    end
  end
  
  def self.template(template_file)
    @template ||= {}
    @template[template_file] ||= ERB.new(File.read(template_file))
    @template[template_file]
  end
  
  def self.generate(karidoc_path, *description_files)
    new(karidoc_path, *description_files).generate
  end
  
  def self.freeze_assets(karidoc_path)
    new(karidoc_path).freeze_assets
  end
  
  def self.clear(karidoc_path, full_name)
    file_name = RubyName.karidoc_filename(karidoc_path, full_name)
    dir_name  = File.dirname(file_name)
    
    begin
      FileUtils.rm(file_name)
    rescue Errno::ENOENT
    end
    
    clear_if_empty(dir_name)
    
    compute_relative_path_from_root(karidoc_path, file_name)
  end
  
  def self.clear_if_empty(dir_name)
    if File.exist?(dir_name) and (Dir.entries(dir_name) - %w(. ..)).empty?
      FileUtils.rm_rf(dir_name)
      clear_if_empty(File.dirname(dir_name))
    end
  end
  
  def self.compute_relative_path_from_root(karidoc_path, filename)
    filename[karidoc_path.length..-1]
  end
  
  def self.compute_relative_path_to_root(karidoc_path)
    level = karidoc_path.split('/').length-2
    level = 0 if level < 0
    (['..']*level).join('/')
  end  
end