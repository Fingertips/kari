require 'yaml'
require 'fileutils'
require 'rdoc/ri/ri_descriptions'
require 'rdoc/markup/simple_markup/to_flow'

module RI
  class Description
    include DescriptionExtensions
  end
end

# Class that generates Karidoc files from the RI description
class KaridocGenerator
  EXTENSION = '.karidoc'
  
  attr_accessor :description_files
  
  def initialize(*description_files)
    self.description_files = description_files.flatten
  end
  
  def generate
    descriptions = description_files.map do |file|
      description = YAML.load_file(file)
      description.filename = file
      description
    end
    
    full_name = descriptions.first.full_name
    karidoc_filename = self.class.filename(full_name, description_files.first)
    
    FileUtils.mkdir_p(File.dirname(karidoc_filename))
    File.open(karidoc_filename, 'w') do |file|
      file.write(render(descriptions))
    end
    karidoc_filename
  end
  
  def render(descriptions)
    template_path = File.expand_path('../../views/karidoc', __FILE__)
    template_file = File.join(template_path, 'layout.erb')
    
    partials = ['method', 'class', 'module'].inject({}) do |partials, t|
      partials[t] = self.class.template(File.join(template_path, "#{t}.erb")); partials
    end
    
    namespace = Namespace.new(
      :descriptions => descriptions,
      :full_name => descriptions.first.full_name,
      :template_path => template_path,
      :stylesheet => File.expand_path('../../assets/karidoc.css', __FILE__),
      :partials => partials
    )
    namespace.extend HTMLHelpers
    namespace.extend FlowHelpers
    
    self.class.template(template_file).result(namespace.binding)
  end
  
  def self.template(template_file)
    @template ||= {}
    @template[template_file] ||= ERB.new(File.read(template_file))
    @template[template_file]
  end
  
  def self.generate(*description_files)
    new(*description_files).generate
  end
  
  def self.clear(full_name, description_filename)
    file_name = filename(full_name, description_filename)
    dir_name  = File.dirname(file_name)
    
    FileUtils.rm_f(file_name)
    clear_if_empty(dir_name)
    
    file_name
  end
  
  def self.clear_if_empty(dir_name)
    if File.exist?(dir_name) and (Dir.entries(dir_name) - %w(. ..)).empty?
      FileUtils.rm_rf(dir_name)
      clear_if_empty(File.dirname(dir_name))
    end
  end
  
  # Returns the filename where the karidoc file for the Ruby name _name_ will be stored.
  #
  # Example:
  #   KaridocGenerator.filename('Module::SubModule.method', '/path/to/Module/Submodule/method-i.yaml') => '/path/to/Module/SubModule/method.karidoc'
  def self.filename(name, description_filename)
    if description_filename =~ /^.*-(i|c).yaml/
      prefix = ($1 == 'c') ? 'class-method-' : 'instance-method-'
    end
    parts = RubyName.split(name)
    parts[-1] = "#{prefix}#{parts[-1]}"
    File.join(filepath, parts.compact.join(File::SEPARATOR) + EXTENSION)
  end
  
  # Returns the path to where all the Karidoc files are written
  def self.filepath
    File.join(Rucola::RCApp.application_support_path, 'Karidoc')
  end
end