require 'log'

module Kernel
  # Returns a logger instance
  #
  # Examples:
  #
  #   log.level = Log::DEBUG
  #   log.info "Couldn't load preferences, using defaults"
  #   log.debug "Initiating primary foton drive…"
  #
  # For more information see the Rucola::Log class.
  def log
    Log.instance
  end
  
  def preferences
    NSUserDefaults.standardUserDefaults
  end
end