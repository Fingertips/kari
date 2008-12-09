require 'cgi'

# Convenience methods for working with Ruby names
class RubyName
  # Splits a name like Module::SubModule.method into a list of parts
  def self.split(name)
    name.to_s.split(/::|#|\./)
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
end