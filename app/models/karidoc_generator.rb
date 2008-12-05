require 'yaml'
require 'fileutils'

# Class that generates Karidoc files from the RI description
class KaridocGenerator
  EXTENSION = '.karidoc'
  
  attr_accessor :description_files
  
  def initialize(description_files)
    self.description_files = description_files
  end
  
  def generate
    descriptions = description_files.map { |file| YAML.load_file(file) }
    
    full_name = descriptions.first.full_name
    karidoc_filename = self.class.filename(full_name)
    
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
      :partials => partials
    )
    namespace.extend HTMLHelpers
    namespace.extend FlowHelpers
    descriptions.map { |description| description.extend DefinitionExtensions }
    
    self.class.template(template_file).result(namespace.binding)
  end
  
  def self.template(template_file)
    @template ||= {}
    @template[template_file] ||= ERB.new(File.read(template_file))
    @template[template_file]
  end
  
  def self.generate(description_files)
    new(description_files).generate
  end
  
  def self.clear(full_name)
    file_name = filename(full_name)
    dir_name  = File.dirname(file_name)
    
    FileUtils.rm_f(file_name)
    clear_if_empty(dir_name)
  end
  
  def self.clear_if_empty(dir_name)
    if (Dir.entries(dir_name) - %w(. ..)).empty?
      FileUtils.rm_rf(dir_name)
      clear_if_empty(File.dirname(dir_name))
    end
  end
  
  # Returns the filename where the karidoc file for the Ruby name _name_ will be stored.
  #
  # Example:
  #   KaridocGenerator.filename('Module::SubModule.method') => '/path/to/Module/SubModule/method.karidoc'
  def self.filename(name)
    File.join(filepath, RubyName.split(name).join(File::SEPARATOR) + EXTENSION)
  end
  
  # Returns the path to where all the Karidoc files are written
  def self.filepath
    File.join(Rucola::RCApp.application_support_path, 'Karidoc')
  end
end