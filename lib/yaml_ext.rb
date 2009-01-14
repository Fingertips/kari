# require 'yaml'
# 
# class Object
#   class << self
#     alias_method :inherited_before_to_yaml, :inherited
#     
#     def inherited(subklass)
#       inherited_before_to_yaml if respond_to?(:inherited_before_to_yaml)
#       p subklass
#       subklass.class_eval do
#         yaml_as "tag:ruby.yaml.org,2002:object:#{name}"
#         
#         def self.yaml_new(klass, tag, values)
#           object = alloc # FIXME: no call to init, because the initilialize might take arguments, potentially dangerous
#           values.each { |k,v| object.send(:instance_variable_set, "@#{k}", v) }
#           object
#         end
#       end
#     end
#   end
# end #unless Object.respond_to?(:inherited_before_to_yaml, true)