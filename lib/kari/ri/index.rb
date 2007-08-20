require 'yaml'
require 'fileutils'
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
        @data = {}
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
      #
      # Options:
      # * <tt>:from</tt>: Don't build and index for RI files older than :from, expects a Time instance
      def rebuild(paths, options={})
        @data = paths.inject(@data) do |index, path|
          self.class.build_for(path, options).each do |key, value|
            if index.has_key?(key)
              index[key] += value
            else
              index[key] = value
            end
          end; index
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

      # Returns the record for the specified full_name
      def get(full_name)
        @data[full_name.split('::').last.split('#').last].find { |record| record[:full_name] == full_name }
      rescue IndexError, NoMethodError
        nil
      end

      # Search the 'needle' in the specified namespace, simulating the way Ruby finds include module.
      def find_included_class(namespace, needle)
        namespace = namespace.split('::')
        (0..namespace.length-1).to_a.each do |index|
          entry = get("#{namespace[0..-(index+1)].join('::')}::#{needle}")
          return entry if entry
        end
        get(needle)
      end

      private

      # Convert a query to a regular expression
      def prepare_query(query)
        return query if query.is_a?(Regexp)
        Regexp.new(query.split.map do |term|
          Regexp.quote(term)
        end.join('|'), Regexp::IGNORECASE, 'u')
      end

      class << self
        # Creates a new index instance and loads the index from the users' homedir.
        def load
          index = new
          index.read_from default_path
          index
        end

        # Builds the index for a specifix RI path and returns the resulting data
        #
        # Options:
        # * <tt>:from</tt>: Don't build and index for RI files older than :from, expects a Time instance
        def build_for(path, options={})
          index = {}

          created = File.join(path, 'created.rid')
          if File.exist?(created)
            created = Time.parse(File.read(created))
            return index if options[:from] and options[:from] > created
          end

          Dir.foreach(path) do |filename|
            next if filename =~ /(^\.)|(\.rid$)/
            current_file = File.join(path, filename)
            if filename =~ /^cdesc-.*\.yaml$|(c|i)\.yaml$/
              definition = YAML::load_file(current_file)
              index[definition.name] ||= []
              index[definition.name] << {
                :full_name => definition.full_name,
                :definition_file => current_file
              }
            else
              if File.directory?(current_file)
                build_for(current_file, options).each do |key, value|
                  if index.has_key?(key)
                    index[key] += value
                  else
                    index[key] = value
                  end
                end
              else
                $stderr.write ">> Don't know how to build index for: #{current_file}\n"
              end
            end
          end
          index
        end

        # Builds or rebuilds the index, writes it to disk and returns it. You can specify a list of paths to build
        # the index from, by default an index for all the RI files will be built.
        #
        # Options:
        # * <tt>:paths</tt>: Paths to load the RI documentation from
        # * <tt>:output_file</tt>: Write the updated index to this path
        # * <tt>:from</tt>: Don't build and index for RI files older than :from, expects a Time instance
        def rebuild(options={})
          options[:paths] ||= ENV["KARI_RI_PATH"] ? [ENV["KARI_RI_PATH"]] : ::RI::Paths.path(true, true, true, true)
          options[:output_file] ||= default_path

          index = new

          if File.exist?(options[:output_file])
            options[:from] ||= File.ctime(options[:output_file])
            index.read_from default_path
            $stderr.write ">> Read index from: #{default_path}\n"
          end

          index.rebuild options.delete(:paths), options

          directory = File.dirname(options[:output_file])
          FileUtils.mkdir_p(directory) unless File.exist?(directory)
          index.write_to options[:output_file]
          index
        end

        # Returns the default storage path for the index
        def default_path
          File.expand_path(File.join(ENV["KARI_HOME"]||ENV["HOME"], '.kari', 'index.marshal'))
        end
      end
    end
  end
end