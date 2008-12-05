# Hack to get around the fact that we don't use rubygems in release.
# Need to think of a solution for this....
module Gem
  class << self
    def path
      ["/System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/lib/ruby/gems/1.8", "/Library/Ruby/Gems/1.8"]
    end
  end
end

require 'rdoc/ri/ri_paths'
require 'rdoc/ri/ri_descriptions'
require 'rdoc/markup/simple_markup/to_flow'

class Manager
  SYSTEM_RI_PATH = RI::Paths.path(true, false, false, false).first
  
  attr_accessor :descriptions, :namespace, :search_index
  
  def initialize
    log.debug "Initializing new indices"
    @descriptions = {}
    @namespace = HashTree.new
    
    if File.exist?(search_index_filename)
      @search_index = SearchKit::Index.open(search_index_filename, nil, true)
    else
      ensure_filepath!
      @search_index = SearchKit::Index.create(search_index_filename)
    end
  end
  
  def length
    @descriptions.length
  end
  
  def add_karidoc_to_namespace(full_name)
    @namespace.set(RubyName.split(full_name), KaridocGenerator.filename(full_name))
  end
  
  def add_description(full_name, file)
    @descriptions[full_name] ||= []
    @descriptions[full_name] << file unless @descriptions[full_name].include?(file)
    @descriptions[full_name].sort! do |a, b|
      if a.start_with?(SYSTEM_RI_PATH)
        -1
      elsif b.start_with?(SYSTEM_RI_PATH)
        1
      else
        b <=> a
      end
    end
  end
  
  def add(full_name, file)
    add_description(full_name, file)
    add_karidoc_to_namespace(full_name)
    
    if description_files = @descriptions[full_name]
      karidoc_filename = KaridocGenerator.generate(description_files)
      @search_index.removeDocument(karidoc_filename)
      @search_index.addDocument(karidoc_filename)
    end
  end
  
  def delete(full_name, file)
    @descriptions[full_name].delete(file)
    if @descriptions[full_name].empty?
      log.debug "Deleting description for `#{full_name}'"
      @descriptions.delete(full_name)
      @namespace.set(RubyName.split(full_name), nil)
      KaridocGenerator.clear(full_name)
      @search_index.removeDocument(KaridocGenerator.filename(full_name))
    else
      KaridocGenerator.generate(@descriptions[full_name])
      karidoc_filename = KaridocGenerator.filename(filename)
      @search_index.removeDocument(karidoc_filename)
      @search_index.addDocument(karidoc_filename)
    end
  end
  
  def purge_vanished(path)
    @descriptions.each do |full_name, files|
      files.each do |file|
        if !File.exist?(file) and file.start_with?(path)
          delete(full_name, file)
        end
      end
    end
  end
  
  def merge_new(path)
    log.debug "Merging RI files for #{path}"
    Dir.foreach(path) do |filename|
      next if filename =~ /(^\.)|(\.rid$)/
      current_path = File.join(path, filename)
      if filename =~ /^cdesc-.*\.yaml$|(c|i)\.yaml$/
        description = YAML::load_file(current_path)
        add(description.full_name, current_path)
      else
        if File.directory?(current_path)
          examine(current_path)
        end
      end
    end
  end
  
  def examine(path)
    purge_vanished(path)
    merge_new(path)
  end
  
  def filepath
    Rucola::RCApp.application_support_path
  end
  
  def ensure_filepath!
    FileUtils.mkdir_p(filepath) unless File.exist?(filepath)
  end
  
  def filename
    File.join(filepath, 'RiIndex')
  end
  
  def search_index_filename
    File.join(filepath, 'SKIndex')
  end
  
  def exist?
    File.exist?(filename)
  end
  
  def write_to_disk
    log.debug "Writing index to disk"
    ensure_filepath!
    File.open(filename, 'w') do |file|
      file.write(Marshal.dump([@descriptions, @namespace]))
    end
  end
  
  def read_from_disk
    File.open(filename, 'r') do |file|
      @descriptions, @namespace = Marshal.load(file.read)
      log.debug "Read index from disk"
    end if exist?
  end
  
  def close
    @search_index.close
  end
  
  def self.initialize_from_disk
    index = new
    index.read_from_disk
    index
  end
end