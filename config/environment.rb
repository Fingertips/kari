Rucola::Initializer.run do |config|
  config.load_path (RCApp.root_path + 'app/helpers').to_s
  
  config.framework 'WebKit'
  
  config.require 'objc_ext/ns_user_defaults'
  config.require 'objc_ext/ns_rect'
  
  Thread.abort_on_exception = true
  
  # FIXME: Hack to get around the fact that we don't use rubygems in release.
  module Gem
    def self.path
      ["/System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/lib/ruby/gems/1.8", "/Library/Ruby/Gems/1.8"]
    end
  end
end