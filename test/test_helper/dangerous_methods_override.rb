# We don't want test running actual commands
module Kernel
  def self.system(*args)
    raise RuntimeError, 'Please stub Kernel.system in your tests'
  end
end