%w(array kernel nil_class string).each do |name|
  require File.expand_path("../core_ext/#{name}", __FILE__)
end