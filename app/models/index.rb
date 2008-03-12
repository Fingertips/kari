require 'rdoc/ri/ri_paths'
require 'rdoc/ri/ri_descriptions'
require 'rdoc/markup/simple_markup/to_flow'

class Index
  SYSTEM_RI_PATH = RI::Paths.path(true, false, false, false).first
  
  attr_accessor :definitions, :tree
  
  def initialize
    log.debug "Initializing new index"
    @definitions = {}
    @tree = {}
  end
  
  def length
    @definitions.length
  end

  def merge_into_tree(docname, path, at)
    at ||= {}
    unless path.length == 1
      at[path.first] = docname
    else
      at[path.first] = merge_into_tree(docname, path[1..-1], at[path.first])
    end
    at
  end
  
  def add_definition_to_tree(full_name)
    @tree = merge_into_tree(full_name, path_for_name(full_name), @tree)
  end
  
  def add_definition_to_index(full_name, file)
    @definitions[full_name] ||= []
    @definitions[full_name] << file unless @definitions[full_name].include?(file)
    @definitions[full_name].sort! do |a, b|
      if a.starts_with?(SYSTEM_RI_PATH)
        -1
      elsif b.starts_with?(SYSTEM_RI_PATH)
        1
      else
        b <=> a
      end
    end
  end
  
  def add(full_name, file)
    add_definition_to_index(full_name, file)
    add_definition_to_tree(full_name)
  end
  
  def examine(path)
    Dir.foreach(path) do |filename|
      next if filename =~ /(^\.)|(\.rid$)/
      current_path = File.join(path, filename)
      if filename =~ /^cdesc-.*\.yaml$|(c|i)\.yaml$/
        definition = YAML::load_file(current_path)
        add(definition.full_name, current_path)
      else
        if File.directory?(current_path)
          examine(current_path)
        end
      end
    end
  end
  
  def filepath
    File.join(OSX.NSHomeDirectory, 'Library', 'Application Support', 'Kari')
  end
  
  def filename
    File.join(filepath, 'RiIndex')
  end
  
  def exist?
    File.exist?(filename)
  end
  
  def write_to_disk
    log.debug "Writing index to disk"
    FileUtils.mkdir_p(filepath) unless File.exist?(filepath)
    File.open(filename, 'w') do |file|
      file.write(Marshal.dump(@definitions))
    end
  end
  
  def read_from_disk
    File.open(filename, 'r') do |file|
      @definitions = Marshal.load(file.read)
      log.debug "Read index from disk"
    end if exist?
  end
  
  def self.initialize_from_disk
    index = new
    index.read_from_disk
    index
  end
  
  private
  
  def path_for_name(name)
    name.split(/::|#|\./)
  end
  
  def name_for_path(path)
    path.join("::")
  end
end