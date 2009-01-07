require 'set'
require 'rucola/fsevents'
require (defined?(MACRUBY_VERSION) ? 'rdoc/ri/paths' : 'rdoc/ri/ri_paths')

class Watcher
  DEVELOPMENT_FILTER = /nap|json|finger|activerecord/i
  
  attr_accessor :fsevents, :delegate
  
  def initialize
    @fsevents = Rucola::FSEvents.start_watching(watchPaths, :since => lastEventId, :latency => 5.0) do |events|
      handleEvents(events)
    end
  end
  
  def riPaths
    #@riPaths ||= RI::Paths.path(true, true, true, true)
    @riPaths ||= RI::Paths.path(true, true, true, true).grep(DEVELOPMENT_FILTER)
  end
  
  def watchPaths
    @watchPaths ||= RI::Paths.path(true, false, false, false) + basePaths(RI::Paths.path(false, true, true, true))
  end
  
  def kariPath
    File.join(Rucola::RCApp.root_path, 'bin', 'kari')
  end
  
  def lastEventId
    PreferencesController.preferences['LastFSEventId']
  end
  
  def setLastEventId(id)
    log.debug("Setting last event ID to #{id}")
    PreferencesController.preferences['LastFSEventId'] = id
  end
  
  def handleEvents(events)
    path = baseDir(events.map { |e| e.path })
    log.debug "Found changes in `#{path}'"
    if path =~ DEVELOPMENT_FILTER
      runKaridocUpdateCommandWithPaths(path)
    else
      log.debug "Skipping `#{path}' because we're just testing right now"
    end
    setLastEventId(events.last.id)
  end
  
  def forceRebuild
    runKaridocUpdateCommandWithPaths(riPaths)
  end
  
  def runKaridocUpdateCommandWithPaths(*paths)
    quoted_paths = paths.flatten.map { |path| "'#{path}'" }.join(' ')
    command = "#{kariPath} update-karidoc #{quoted_paths}"
    
    if delegate and delegate.respond_to?(:startedIndexing)
      delegate.startedIndexing(self)
    end
    
    log.debug "Starting thread: #{command}"
    Thread.start do
      Kernel.system(command)
    end
  end
  
  def examineAll
    examine(riPaths)
  end
  
  def examine(*paths)
    paths.flatten.each do |path|
      Manager.instance.examine(path)
      Manager.instance.write_to_disk
    end
    NSDistributedNotificationCenter.defaultCenter.
      postNotificationName 'KariDidFinishIndexing', object: nil
  end
  
  def stop
    @fsevents.stop
  end
  
  protected
  
  # Finds the longest shared path between the two paths
  def union(leftpath, rightpath)
    union = []
    
    left = leftpath.split(File::SEPARATOR)
    right = rightpath.split(File::SEPARATOR)
    
    0.upto(left.length-1) do |index|
      if left[index] == right[index]
        union << left[index]
      else
        break
      end
    end
    union.join(File::SEPARATOR)
  end
  
  # Returns the smallest list of common directories for the supplied paths
  def basePaths(paths)
    bases = Set.new
    paths.each do |left|
      paths.each do |right|
        unless left == right
          base = union(left, right)
          unless base.empty?
            bases << base
          end
        end
      end
    end
    bases.to_a
  end
  
  # Returns the largest common path between the paths
  def baseDir(paths)
    paths = paths.dup
    current = paths.pop
    while path = paths.pop
      current = union(current, path)
    end
    current
  end  
end