require 'yaml'
require 'fileutils'

# Class that generates Karidoc files from the RI definition
class Generator
  EXTENSION = '.karidoc'
  
  def self.generate(description_files)
    descriptions = description_files.map { |file| YAML.load_file(file) }
    
    full_name = descriptions.first.full_name
    filename = filename(full_name)
    
    FileUtils.mkdir_p(File.dirname(filename))
    File.open(filename, 'w') do |file|
      file.write('Nothing.')
    end
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