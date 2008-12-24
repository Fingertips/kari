require File.expand_path('../../lib/SACrashReporter', __FILE__)

#########
# helpers
#########

class Object
  # A simple alias to be a bit less verbose while testing.
  #
  #   obj.ivar(:@foo) #=> the object that is referenced by the instance variable @foo in the object 'obj'
  alias_method :ivar, :instance_variable_get
  
  def ib_outlet(ivar)
    instance_eval "@#{ivar}"
  end
end

#########
# Mocking
#########

class ReportSubclass < SACrashReporter::Report
  def crap
    "crap!"
  end
  def even_more_crap
    "even more crap!"
  end
end

BACKTRACE_MOCK = 'Some random exception.'
def BACKTRACE_MOCK.backtrace
["/Users/eloy/Documents/DEVELOPMENT/RubyCocoa/SARubyCocoaExtensions/SAAppKit/HDCrashReporter/lib/report.rb:34:in `send'",
"/Users/eloy/Documents/DEVELOPMENT/RubyCocoa/SARubyCocoaExtensions/SAAppKit/HDCrashReporter/lib/report.rb:34:in `get'",
"./test/test_report.rb:57:in `test_spec {SACrashReporter::Report} 008 [should return the apps PID]'",
"/opt/local/lib/ruby/gems/1.8/gems/mocha-0.5.5/lib/mocha/test_case_adapter.rb:19:in `__send__'",
"/opt/local/lib/ruby/gems/1.8/gems/mocha-0.5.5/lib/mocha/test_case_adapter.rb:19:in `run'"]
end

DEFAULT_APPLE_STYLE_CRASH_VALUES = {
  :os_version => ['OS Version:', '10.4.10 (8R2232)'],
  :command => ['Command:', 'Foo'],
  :path => ['Path:', '/Applications/Foo.app/Contents/MacOS/Foo'],
  :version => ['Version:', "1.0 final (1.0)"],
  :pid => ['PID:', '10999'],
  :ruby_version => ["Ruby Version:", RUBY_VERSION],
  :rubycocoa_version => ["RubyCocoa Version:", OSX::RUBYCOCOA_VERSION],
  :date_time => ['Date/Time:', '123456789']
}

DEFAULT_APPLE_STYLE_CRASH_MESSAGE = %{

**********

        Host Name: #{`hostname`.chomp}
        Date/Time: #{DEFAULT_APPLE_STYLE_CRASH_VALUES[:date_time].last}
       OS Version: #{DEFAULT_APPLE_STYLE_CRASH_VALUES[:os_version].last}
     Ruby Version: #{DEFAULT_APPLE_STYLE_CRASH_VALUES[:ruby_version].last}
RubyCocoa Version: #{DEFAULT_APPLE_STYLE_CRASH_VALUES[:rubycocoa_version].last}
   Report Version: SACrashReporter version #{SACrashReporter::VERSION}

          Command: #{DEFAULT_APPLE_STYLE_CRASH_VALUES[:command].last}
             Path: #{DEFAULT_APPLE_STYLE_CRASH_VALUES[:path].last}

          Version: #{DEFAULT_APPLE_STYLE_CRASH_VALUES[:version].last}

              PID: #{DEFAULT_APPLE_STYLE_CRASH_VALUES[:pid].last}

        Exception: #{BACKTRACE_MOCK}

BACKTRACE:
#{BACKTRACE_MOCK.backtrace.join("\n")}}

CUSTOM_ORDER_AND_SELECTION_MESSAGE = %{

**********

 Host Name: #{`hostname`.chomp}

OS Version: #{DEFAULT_APPLE_STYLE_CRASH_VALUES[:os_version].last}
       PID: #{DEFAULT_APPLE_STYLE_CRASH_VALUES[:pid].last}\n\n}

CUSTOM_LOGS_MESSAGE = %{

**********

          Crap: crap!

    OS Version: #{DEFAULT_APPLE_STYLE_CRASH_VALUES[:os_version].last}
Even More Crap: even more crap!\n\n}
