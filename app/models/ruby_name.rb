require 'cgi'

# Convenience methods for working with Ruby names
class RubyName
  KARIDOC_EXTENSION = '.karidoc'
  
  # Splits a name like Module::SubModule#method into a list of parts
  def self.split(name)
    path = name.to_s.split(/::|\./)
    if path.last =~ /#/
      parts = path[-1].split(/#/)
      parts[-1] = "##{parts[-1]}"
      path[-1] = parts
      path.flatten!
    end
    path
  end
  
  # Converts a RI filename to a RubyName
  def self.from_ri_filename(filename, basepath='')
    parts = filename[basepath.length+1..-1].split(File::SEPARATOR)
    module_name = parts[0..-2].join('::')
    
    full_name = case parts.last
    when /^cdesc-\w*.yaml$/
      module_name
    when /^(.*)-(i|c).yaml/
      [module_name, CGI.unescape($1)].join($2 == 'i' ? '#' : '::')
    else
      raise ArgumentError, "Unknown RI definition file: #{parts.last}"
    end
  end
  
  # Converts a Karidoc filename to a RubyName
  def self.from_karidoc_filename(filename)
    parts = filename[karidoc_filepath.length+1..-1].split(File::SEPARATOR)
    parts[-1] = File.basename(parts[-1], '.karidoc')
    if parts.last =~ /^#/
      parts[-2..-1] = parts[-2..-1].join
    end
    parts.join('::')
  end
  
  # Returns the filename where the karidoc file for the Ruby name _name_ will be stored.
  #
  # Example:
  #   RubyName.karidoc_filename('Module::SubModule#method') => '/path/to/Module/SubModule/#method.karidoc'
  def self.karidoc_filename(name)
    File.join(karidoc_filepath, RubyName.split(name).join(File::SEPARATOR) + KARIDOC_EXTENSION)
  end
  
  # Returns the path where all the Karidoc files are written
  def self.karidoc_filepath
    File.join(Rucola::RCApp.application_support_path, 'Karidoc')
  end
end