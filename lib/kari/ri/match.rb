module Kari #:nodoc:
  module RI #:nodoc:

    # A Match object wraps RI definition objects in order to get a nice and consistant interface to the underlying data.
    class Match

      # Creates a new Match instance. Entry should be an entry from the index, index is the index itself.
      def initialize(entry, index)
        @entry, @index = entry, index
      end

      # Returns the RI definition of the matched object
      def definition
        @definition ||= YAML.load_file(@entry[:definition_file])
      end

      # Returns the full_name of the matched object
      def full_name
        @entry[:full_name]
      end

      # Returns the nesting path for the matched object
      def path
        @entry[:full_name].split('::')[0..-2].join('::')
      end

      # Returns an array of Match instances which represent the methods
      def class_methods
        definition.class_methods.map do |method|
          Match.new(@index.get("#{full_name}::#{method.name}"), @index)
        end
      end

      def instance_methods
        definition.instance_methods.map do |method|
          Match.new(@index.get("#{full_name}##{method.name}"), @index)
        end
      end

      # Allows us to call attributes on the definition directly through the Match instance
      def method_missing(m, *a, &b)
        definition.send(m, *a, &b)
      rescue NoMethodError => e
        raise e
      end
    end
  end
end