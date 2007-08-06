require 'rdoc/ri/ri_options'
require 'rdoc/ri/ri_paths'
require 'rdoc/ri/ri_reader'
require 'rdoc/ri/ri_cache'

module RI
  class KariFormatter
    def display_header(text, level, ident)
      level = 4 if level > 4
      tag("h#{level}") { "Pew pew: #{text}" }
      puts
    end
  end
end

module Kari
  module Search
    class NotFound < Exception; end

    class Index
      def initialize
        @options = RI::Options.instance
        @reader = RI::RiReader.new(RI::RiCache.new(@options.path))
      end

      def search(term)
        descriptor = NameDescriptor.new(term)

        # The initial list of namespaces is everything
        namespaces = @reader.top_level_namespace

        # First try to match class names
        descriptor.class_names.each do |name|
          namespaces = @reader.lookup_namespace_in(name, namespaces)
          raise NotFound, "Couldn't find a match for #{term}" if namespaces.empty?
        end

        # Try to find an exact match
        class_name = descriptor.full_class_name
        found = namespaces.find_all { |ns| ns.full_name == class_name }
        namespaces = found if found.size == 1

        if descriptor.method_name.nil? # We've found classes
          render_classes(namespaces)
        else # We've found methods
          methods = @reader.find_methods(descriptor.method_name, descriptor.is_class_method, namespaces)
          render_methods(methods, descriptor.method_name)
        end
      end

      def render_classes(classes)
        classes.to_s
      end

      def render_methods(methods, method_name)
        if methods.length == 1
          method = @reader.get_method(methods.first)
        else
          entries = methods.find_all { |m| m.name == method_name }
        end
      end

      def self.search(term)
        sr = self.new
        sr.search term
      end
    end
  end
end

puts Kari::Search::Index.search('link_to')