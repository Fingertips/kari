require 'fileutils'

module Controllers
  def stub_outlets(controller, mapping)
    mapping.each do |outlet, instance|
      instance_variable_set("@#{outlet}", instance)
      controller.send("#{outlet}=", instance)
    end
  end
end