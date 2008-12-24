Rucola::Initializer.run do |config|
  # Settings specified in environment/release.rb and environment/debug.rb take precident
  # over these settings.
  #
  # Load any custom Objective-C frameworks
  # config.objc_frameworks = %w(webkit quartz iokit)
  #
  # Use active_record bindings
  # config.use_active_record = true
  
  config.objc_frameworks = %w{ WebKit }
  
  Thread.abort_on_exception = true
  
  # FIXME: Hack to get around the fact that we don't use rubygems in release.
  module Gem
    def self.path
      ["/System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/lib/ruby/gems/1.8", "/Library/Ruby/Gems/1.8"]
    end
  end
end