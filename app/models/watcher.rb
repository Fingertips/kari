require 'set'
require 'rucola/fsevents'
require 'rdoc/ri/ri_paths'

class Watcher
  DEVELOPMENT_FILTER = /nap|json|finger|activerecord/i
  
  attr_accessor :fsevents
  
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
      rebuild(path)
    else
      log.debug "Skipping `#{path}' because we're just testing right now"
    end
    setLastEventId(events.last.id)
  end
  
  def forceRebuild
    rebuild(riPaths)
  end
  
  def rebuild(*paths)
    OSX::NSNotificationCenter.defaultCenter.postNotificationName_object('KariDidStartIndexingNotification', nil)
    paths.flatten.each do |path|
      Manager.instance.examine(path)
      Manager.instance.write_to_disk
    end
    OSX::NSNotificationCenter.defaultCenter.postNotificationName_object('KariDidFinishIndexingNotification', nil)
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