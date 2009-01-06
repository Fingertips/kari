require 'set'
require 'rucola/fsevents'
require 'rdoc/ri/ri_paths'

class Watcher < OSX::NSObject
  attr_accessor :fsevents, :delegate
  
  def initWithWatchers
    if init
      log.debug("Watching FSEvents since #{lastEventId}")
      @fsevents = Rucola::FSEvents.start_watching(watchPaths, :since => lastEventId, :latency => 5.0) do |events|
        handleEvents(events)
      end
      OSX::NSDistributedNotificationCenter.defaultCenter.objc_send(
        :addObserver, self,
           :selector, 'finishedUpdating:',
               :name, 'KariDidFinishUpdating',
             :object, nil
      )
      OSX::NSDistributedNotificationCenter.defaultCenter.objc_send(
        :addObserver, self,
           :selector, 'finishedReplacing:',
               :name, 'KariDidFinishReplacing',
             :object, nil
      )
      self
    end
  end
  
  def riPaths
    RI::Paths.path(true, true, true, true)
  end
  
  def watchPaths
    RI::Paths.path(true, false, false, false) + self.class.basePaths(RI::Paths.path(false, true, true, true))
  end
  
  def kariPath
    "env RUBYCOCOA_ROOT=#{Rucola::RCApp.root_path} RUBYCOCOA_ENV=#{Rucola::RCApp.env} #{File.join(Rucola::RCApp.root_path, 'bin', 'kari')}"
  end
  
  def lastEventId
    PreferencesController.preferences['LastFSEventId']
  end
  
  def setLastEventId(id)
    log.debug("Setting last event ID to #{id}")
    PreferencesController.preferences['LastFSEventId'] = id
    PreferencesController.synchronize
  end
  
  def handleEvents(events)
    paths = events.map { |e| e.path }
    log.debug "Found changes in #{paths.inspect}"
    paths = self.class.basePaths(paths)
    log.debug "Using paths: #{paths.inspect}"
    runKaridocUpdateCommandWithPaths(paths)
    setLastEventId(events.last.id)
  end
  
  def forceRebuild
    runKaridocUpdateCommandWithPaths(watchPaths)
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
      OSX::NSDistributedNotificationCenter.defaultCenter.objc_send(
        :postNotificationName, 'KariDidFinishUpdating', :object, nil
      )
    end
  end
  
  def finishedUpdating(notification)
    log.debug "Got notification: KariDidFinishUpdating"
    runKaridocReplaceCommand
  end
  
  def runKaridocReplaceCommand
    command = "#{kariPath} replace-karidoc"
    log.debug "Starting thread: #{command}"
    Thread.start do
      Kernel.system(command)
      OSX::NSDistributedNotificationCenter.defaultCenter.objc_send(
        :postNotificationName, 'KariDidFinishReplacing', :object, nil
      )
    end
  end
  
  def finishedReplacing(notification)
    log.debug "Got notification: KariDidFinishReplacing"
    if delegate and delegate.respond_to?(:finishedIndexing)
      delegate.finishedIndexing(self)
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
  end
  
  def stop
    @fsevents.stop
  end
  
  protected
  
  # Finds the longest shared path between the two paths
  def self.union(leftpath, rightpath)
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
    
    path = union.join(File::SEPARATOR)
    path == '' ? '/' : path
  end
  
  # Returns the smallest list of common directories for the supplied paths
  def self.basePaths(paths)
    return paths if paths.length < 2
    bases = Set.new
    paths.each do |path|
      unless bases.any? { |base| path.start_with?(base) }
        candidates = bases.map { |base| [union(base, path), base] }
        unless candidates.empty?
          longest = candidates.sort.last
          unless longest.first == '/'
            bases.delete(longest.last)
            bases << longest.first
          else
            bases << path unless path == '/'
          end
        else
          bases << path unless path == '/'
        end
      end
    end
    bases.to_a
  end
end