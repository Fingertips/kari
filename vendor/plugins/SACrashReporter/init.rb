require File.expand_path('../SACrashReporter', __FILE__)

module Rucola
  class SACrashReporterPlugin < Plugin
    def before_boot
      Initializer.class_eval do
        class << self
          alias_method :do_boot_before_crash_reporter, :do_boot
          define_method :do_boot do
            ::SACrashReporter.run_app { do_boot_before_crash_reporter }
          end
        end
      end
    end
    
    def after_launch
      ::SACrashReporter.submit
    end
  end
end