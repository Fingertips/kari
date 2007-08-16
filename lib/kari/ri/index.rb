require 'logger'
require 'yaml'
require 'rdoc/ri/ri_paths'
require 'rdoc/ri/ri_descriptions'
require 'rdoc/markup/simple_markup/to_flow'

module Kari
  module RI
    class Index
      attr_reader :paths

      def initialize(options={})
        @paths = ::RI::Paths.path(true, true, true, true)
        @logger = Logger.new(STDOUT)
      end

      def build
        index = {}
        @paths.each do |path|
          debug "Building index for #{path}"
          index.merge! build_for(path)
        end
        index
      end

      def build_for(path)
        index = {}
        Dir.foreach(path) do |filename|
          next if filename =~ /(^\.)|(.rid$)/

          current_file = File.join(path, filename)
          if filename =~ /^cdesc-.*.yaml$|(c|i).yaml$/
            definition = read(current_file)
            index[definition.full_name] = current_file
          else
            if File.directory?(current_file)
              index.merge! build_for(current_file)
            else
              debug "Don't know how to build index for: #{current_file}"
            end
          end
        end
        index
      end

      def write_to(filename)
        # OPTIMIZE: buffered writes?
        File.open(filename, 'wb') do |file|
          file.write Marshal.dump(build)
        end
      end

      def read_from(filename)
        # OPTIMIZE: buffered reads please
        index = Marshal.load(File.read(filename))
      end

      private

      def debug(string)
        @logger.debug(string)
      end

      def read(filename)
        YAML::load_file(filename)
      end
    end
  end
end