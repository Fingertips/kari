require 'find'
require 'rdoc/ri/ri_paths'

class Manager
  SYSTEM_RI_PATH         = RI::Paths.path(true, false, false, false).first
  RI_PATH_VERSION_REGEXP = /\/\w*-([\d\.]*)\//
  
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
    unless @descriptions[full_name].include?(file)
      @descriptions[full_name] << file
      @descriptions[full_name].sort! do |a, b|
        if a.start_with?(SYSTEM_RI_PATH)
          -1
        elsif b.start_with?(SYSTEM_RI_PATH)
          1
        else
          left  = RI_PATH_VERSION_REGEXP.match(a)
          right = RI_PATH_VERSION_REGEXP.match(b)
          (left.nil? or right.nil?) ? b <=> a : right[1] <=> left[1]
        end
      end
      true
    else
      false
    end
  end
  
  def add(full_name, file)
    return false unless full_name =~ /^\w/
    
    if add_description(full_name, file)
      add_karidoc_to_namespace(full_name)
      true
    else
      false
    end
  end
  
  def delete(full_name, file)
    if @descriptions[full_name].delete(file)
      if @descriptions[full_name].empty?
        @descriptions.delete(full_name)
        @namespace.set(RubyName.split(full_name), nil)
      end
      true
    else
      false
    end
  end
  
  def purge_vanished(path)
    purge = []
    @descriptions.each do |full_name, files|
      files.each do |file|
        if file.start_with?(path) and !File.exist?(file)
          purge << [full_name, file]
        end
      end
    end
    purge.map { |full_name, file| delete(full_name, file); full_name }
  end
  
  def merge_new(path)
    changed = []
    log.debug "Examining RI files in `#{path}'"
    Find.find(path) do |filename|
      if filename =~ /\.yaml$/
        full_name = RubyName.from_ri_filename(filename, path)
        if add(full_name, filename)
          changed << full_name
        end
      end
    end
    changed
  end
  
  def update(path)
    changed = []
    changed.concat purge_vanished(path)
    Find.find(path) do |filename|
      if filename =~ /\.rid$/
        changed.concat merge_new(File.dirname(filename))
      end
    end
    changed
  end
  
  def update_karidoc(changed)
    log.debug "Updating Karidocs for #{changed.length} descriptions"
    changed.each do |full_name|
      if @descriptions[full_name]
        KaridocGenerator.generate(@descriptions[full_name])
        karidoc_filename = KaridocGenerator.filename(filename)
        @search_index.removeDocument(karidoc_filename)
        @search_index.addDocument(karidoc_filename)
      else
        KaridocGenerator.clear(full_name)
        @search_index.removeDocument(KaridocGenerator.filename(full_name))
      end
    end
  end
  
  def examine(path)
    changed = update(path).uniq
    update_karidoc(changed)
    changed
  end
  
  def search(query)
    @search_index.search(query)
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
    @search_index.flush
    File.open(filename, 'w') do |file|
      file.write(Marshal.dump([@descriptions, @namespace]))
    end
  end
  
  def read_from_disk
    File.open(filename, 'r') do |file|
      @descriptions, @namespace = Marshal.load(file.read)
      log.debug "Read index from disk (#{@descriptions.length} descriptions)"
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
  
  def self.instance
    @instance ||= initialize_from_disk
  end
end