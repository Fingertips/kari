require 'yaml'
require 'fileutils'

# Class that generates Karidoc files from the RI definition
class Generator
  EXTENSION = '.karidoc'
  
  attr_accessor :definition_files
  
  def initialize(definition_files)
    self.definition_files = definition_files
  end
  
  def generate
    definitions = definition_files.map { |file| YAML.load_file(file) }
    
    full_name = definitions.first.full_name
    karidoc_filename = self.class.filename(full_name)
    
    FileUtils.mkdir_p(File.dirname(karidoc_filename))
    File.open(karidoc_filename, 'w') do |file|
      file.write(render(definitions))
    end
  end
  
  def render(definitions)
    template_path = File.expand_path('../../views/karidoc', __FILE__)
    template_file = File.join(template_path, 'layout.erb')
    
    partials = ['method', 'class', 'module'].inject({}) do |partials, t|
      partials[t] = self.class.template(File.join(template_path, "#{t}.erb")); partials
    end
    
    namespace = Namespace.new(
      :definitions => definitions,
      :full_name => definitions.first.full_name,
      :template_path => template_path,
      :partials => partials
    )
    namespace.extend HTMLHelpers
    namespace.extend FlowHelpers
    definitions.map { |definition| definition.extend DefinitionExtensions }
    
    self.class.template(template_file).result(namespace.binding)
  end
  
  def self.template(template_file)
    @template ||= {}
    @template[template_file] ||= ERB.new(File.read(template_file))
    @template[template_file]
  end
  
  def self.generate(description_files)
    generator = Generator.new description_files
    generator.generate
  end
  
  # Returns the filename where the karidoc file for the Ruby name _name_ will be stored.
  #
  # Example:
  #   Generator.filename('Module::SubModule.method') => '/path/to/Module/SubModule/method.karidoc'
  def self.filename(name)
    File.join(filepath, RubyName.split(name).join(File::SEPARATOR) + EXTENSION)
  end
  
  # Returns the path to where all the Karidoc files are written
  def self.filepath
    File.join(Rucola::RCApp.application_support_path, 'Karidoc')
  end
end