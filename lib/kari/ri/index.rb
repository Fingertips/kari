require 'yaml'
require 'logger'
require 'rdoc/ri/ri_paths'
require 'rdoc/ri/ri_descriptions'
require 'rdoc/markup/simple_markup/to_flow'

module Kari #:nodoc:
  module RI #:nodoc:
    
    # Kari's indexer creates a search index for RI's yaml files for easier and faster searching. The index is nothing
    # more than a large hash with string keys for the various methods, classes and modules. Each of the string keys
    # point to the original YAML file where the method, class or module is described.
    class Index
      attr_accessor :data

      # Creates a new Index instance.
      def initialize
        @data = nil
      end

      # Writes the index to a filename
      def write_to(filename)
        # OPTIMIZE: buffered writes?
        File.open(filename, 'wb') do |file|
          file.write Marshal.dump(@data)
        end
      end

      # Reads the index from a filename
      def read_from(filename)
        # OPTIMIZE: buffered reads please
        @data = Marshal.load(File.read(filename))
      end

      # Builds the index for the specified list of paths.
      def build(paths)
        @data = paths.inject({}) do |index, path|
          logger.debug "Building index for #{path}"
          index.merge self.class.build_for(path)
        end
      end

      # Find results for a query in the index
      def find(query)
        return [] if query.nil? or query == ''
        query = prepare_query(query)
        @data.inject([]) do |matches, (key, records)|
          matches += records if key =~ query
          matches
        end
      end
      alias_method :[], :find

      # Convert a query to a regular expression
      def prepare_query(query)
        return query if query.is_a?(Regexp)
        Regexp.new(query.split.map do |term|
          Regexp.quote(term)
        end.join('|'), Regexp::IGNORECASE, 'u')
      end

      private

      # Returns a singleton logger instance for this class
      def logger
        @logger ||= Logger.new(STDOUT)
      end

      class << self

        # Builds the index for a specifix RI path and returns the resulting data
        def build_for(path)
          index = {}
          Dir.foreach(path) do |filename|
            next if filename =~ /(^\.)|(.rid$)/
            current_file = File.join(path, filename)
            if filename =~ /^cdesc-.*.yaml$|(c|i).yaml$/
              definition = YAML::load_file(current_file)
              index[definition.name] ||= []
              index[definition.name] << {
                :full_name => definition.full_name,
                :definition_file => current_file
              }
            else
              if File.directory?(current_file)
                build_for(current_file).each do |key, value|
                  if index.has_key?(key)
                    index[key] += value
                  else
                    index[key] = value
                  end
                end
              else
                logger.debug "Don't know how to build index for: #{current_file}"
              end
            end
          end
          index
        end

        # Builds the index and writes it to the standard location. You can specify a list of paths to build the index
        # from, by default an index for all the RI files will be built.
        def build(options={})
          options[:paths] ||= ::RI::Paths.path(true, true, true, true)
          options[:output_file] ||= File.expand_path('index.marshal', File.dirname(__FILE__))
          index = new
          index.build options[:paths]
          index.write_to options[:output_file]
        end
      end
    end
  end
end