# Convenience methods for working with Ruby names
class RubyName
  # Splits a name like Module::SubModule.method into a list of parts
  def self.split(name)
    name.to_s.split(/::|#|\./)
  end
end