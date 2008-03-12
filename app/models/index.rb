require 'rdoc/ri/ri_paths'

class Index
  SYSTEM_RI_PATH = RI::Paths.path(true, false, false, false).first
  
  def initialize
    log.debug "Initializing new index"
    @data = {}
  end
  
  def length
    @data.length
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
      file.write(Marshal.dump(@index))
    end
  end
  
  def read_from_disk
    File.open(filename, 'r') do |file|
      @index = Marshal.load(file.read)
      log.debug "Read index from disk"
    end if exist?
  end
  
  def self.initialize_from_disk
    index = new
    index.read_from_disk
    index
  end
end