require 'yaml'
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

      # Builds the index and returns the resulting data
      def build
        require 'logger'
        paths = ::RI::Paths.path(true, true, true, true)
        @data = paths.inject({}) do |index, path|
          logger.debug "Building index for #{path}"
          index.merge self.class.build_for(path)
        end
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
              index[definition.full_name] = current_file
            else
              if File.directory?(current_file)
                index.merge! build_for(current_file)
              else
                logger.debug "Don't know how to build index for: #{current_file}"
              end
            end
          end
          index
        end

        # Builds the index and writes it to the standard location
        def build
          index = new
          index.build
          index.write_to(File.expand_path(File.dirname(__FILE__), 'index.marshal'))
        end
      end
    end
  end
end