require 'set'
require 'monitor'
require 'fsevents'
require 'rdoc/ri/paths'

class Watcher
  attr_accessor :fsevents, :delegate
  attr_accessor :examineQueue, :task
  
  include MonitorMixin
  
  def init
    if super
      emptyQueue
      self
    end
  end
  
  def kariPath
    File.join(Kari.root_path, 'bin', 'kari')
  end
  
  def kariEnvironment
    { 'KARI_ROOT' => Kari.root_path, 'KARI_ENV' => Kari.env }.merge(ENV)
  end
  
  def _existing(paths)
    paths.select { |path| File.exist?(path) }
  end
  
  def watchPaths
    _existing(
      %w(/System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/lib/ruby/gems/1.8) +
      self.class.basePaths(RDoc::RI::Paths.raw_path(false, true, true, true))
    )
  end
  
  def riPaths
    _existing(
      %w(/Library/Ruby/Gems/1.8) +
      self.class.basePaths(RDoc::RI::Paths.raw_path(true, true, true, true))
    )
  end
  
  def start
    log.debug("Watching FSEvents since #{lastEventId} on #{watchPaths.inspect}")
    @fsevents = FSEvents.start_watching(watchPaths, :since => lastEventId, :latency => 5.0) do |events|
      handleEvents(events)
    end unless watchPaths.empty?
  end
  
  def stop
    @fsevents.stop if @fsevents
  end
  
  def lastEventId
    preferences['Preferences.General.last_fs_event_id']
  end
  
  def setLastEventId(id)
    log.debug("Setting last event ID to #{id}")
    preferences['Preferences.General.last_fs_event_id'] = id
    preferences.synchronize
  end
  
  def <<(paths)
    log_with_signature("Adding paths to queue: #{paths}")
    examineQueue.synchronize do
      examineQueue.concat paths
    end
    signal
  end
  
  def handleEvents(events)
    unless events.empty?
      paths = events.map { |e| e.path }
      log_with_signature "Found changes in #{paths.inspect}"
      paths = self.class.basePaths(paths)
      log_with_signature "Using paths: #{paths.inspect}"
      self << paths
      setLastEventId(events.last.id)
    end
  end
  
  def execute(*arguments)
    self.task = NSTask.alloc.init
    task.environment = kariEnvironment
    task.launchPath  = kariPath
    task.arguments   = arguments
    task.launch
    task
  end
  
  def signal(sender=nil)
    if !task or !task.isRunning
      delegate.finishedIndexing(self) if delegate and task
      synchronize do
        paths = []
        examineQueue.synchronize do
          paths = self.class.basePaths(examineQueue)
          emptyQueue
        end
        
        unless paths.empty?
          log_with_signature "Starting task for paths: #{paths.inspect}"
          log_with_signature "#{kariPath} update --current-karidoc '#{Manager.instance.filepath}' --next-karidoc '#{Manager.next_filepath}' #{paths.join(' ')}"
          task = execute('update', '--current-karidoc', Manager.instance.filepath, '--next-karidoc', Manager.next_filepath, *paths)
          log_with_signature "Notify the delegate that we started indexing"
          delegate.startedIndexing(self) if delegate
        end
      end
    elsif task and task.isRunning
      log_with_signature "Task is still running"
    end
  end
  
  def forceRebuild
    self << riPaths
  end
  
  def emptyQueue
    self.examineQueue = []
    self.examineQueue.extend(MonitorMixin)
  end
  
  def log_with_signature(message)
    method = caller(1)[0].split(' ').last[1..-2]
    log.info "[#{self.class.name}##{method}] #{message}"
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