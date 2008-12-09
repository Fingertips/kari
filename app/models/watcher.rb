require 'rucola/fsevents'
require 'rdoc/ri/ri_paths'

class Watcher
  attr_accessor :manager, :fsevents
  
  def initialize(options={})
    @manager = options[:manager]
    @fsevents = Rucola::FSEvents.start_watching(riPaths, :since => lastEventId) do |events|
      handleEvents(events)
    end
  end
  
  def riPaths
    RI::Paths.path(true, true, true, true)
  end
  
  def lastEventId
    PreferencesController.preferences['LastFSEventId']
  end
  
  def setLastEventId(id)
    log.debug("Setting last event ID to #{id}")
    PreferencesController.preferences['LastFSEventId'] = id
  end
  
  def buildIndex
    Thread.new do
      riPaths.each { |path| @manager.examine(path) }
      @manager.write_to_disk
      OSX::NSNotificationCenter.defaultCenter.postNotificationName_object('KariDidFinishIndexingNotification', nil)
    end
  end
  
  def handleEvents(events)
    events.each do |event|
      log.debug "Changed file in: #{event.path}"
      log.debug "Changed file is: #{event.last_modified_file}"
    end
    setLastEventId(events.last.id)
  end
  
  def stop
    @fsevents.stop
  end
end