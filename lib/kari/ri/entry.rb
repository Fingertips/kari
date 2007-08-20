module Kari #:nodoc:
  module RI #:nodoc:

    # A Entry object wraps RI definition objects in order to get a nice and consistant interface to the underlying data.
    class Entry

      # Creates a new Entry instance. Entry should be an entry from the index, index is the index itself.
      def initialize(entry, index)
        @entry, @index = entry, index
      end

      # Returns the definition of the RI entry
      def definition
        @definition ||= YAML.load_file(@entry[:definition_file])
      end

      # Returns the full_name, for example: <tt>ActiveSupport::Multibyte::Chars</tt>
      def full_name
        @entry[:full_name]
      end

      # Returns the nesting path for the matched object
      def path
        @entry[:full_name].split(/::|#|\./)[0..-2].join('::')
      end

      # Returns the separator use between the path and the name
      def separator
        if @entry[:full_name] =~ /#/
          '#'
        elsif @entry[:full_name] =~ /\./
          '.'
        else
          '::'
        end
      end

      # Returns an array of Entry instances describing the class methods
      def class_methods
        @class_methods ||= definition.class_methods.map do |method|
          Entry.new(@index.get("#{full_name}::#{method.name}"), @index)
        end if definition.respond_to?(:class_methods)
      end

      # Returns an array of Entry instances describing the instance methods
      def instance_methods
        @instance_methods ||= definition.instance_methods.map do |method|
          Entry.new(@index.get("#{full_name}##{method.name}"), @index)
        end if definition.respond_to?(:instance_methods)
      end

      # Returns as array of Entry instances describing the included modules
      def includes
        @includes ||= definition.includes.map do |inc|
          entry = @index.find_included_class(path, inc.name)
          entry ? Entry.new(entry, @index) : inc.name
        end if definition.respond_to?(:includes)
      end

      # Returns true when the entry is describing a class
      def class?
        definition.class.to_s =~ /Class/
      end

      # Allows us to call attributes on the definition directly through the Entry instance
      def method_missing(m, *a, &b)
        definition.send(m, *a, &b)
      rescue NoMethodError => e
        raise e
      end
    end
  end
end