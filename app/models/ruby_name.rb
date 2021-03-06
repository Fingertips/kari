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
      "#{module_name}#{$2 == 'i' ? '#' : '::'}#{CGI.unescape($1)}"
    else
      raise ArgumentError, "Unknown RI definition file: #{parts.last}"
    end
  end
  
  # Converts a Karidoc filename to a RubyName
  def self.from_karidoc_filename(karidoc_filepath, filename)
    from_karidoc_path(filename[karidoc_filepath.length+1..-1])
  end
  
  # Converts a Karidoc filepath to a RubyName
  def self.from_karidoc_path(filepath)
    parts = filepath.split(File::SEPARATOR)
    if parts.first == ''
      parts = parts[1..-1]
    end
    parts[-1] = File.basename(parts[-1], '.karidoc')
    if parts.last.start_with?('#')
      parts[-2..-1] = parts[-2..-1].join
    end
    parts.join('::')
  end
  
  # Returns the filename where the karidoc file for the Ruby name _name_ will be stored.
  #
  # Example:
  #   RubyName.karidoc_filename('/path/to', 'Module::SubModule#method') => '/path/to/Module/SubModule/#method.karidoc'
  def self.karidoc_filename(karidoc_filepath, name)
    File.join(karidoc_filepath, relative_karidoc_path(name))
  end
  
  # Returns karidoc the path relative to Kari's Application Support path
  def self.relative_karidoc_path(name)
    RubyName.split(name).join(File::SEPARATOR) + KARIDOC_EXTENSION
  end
end