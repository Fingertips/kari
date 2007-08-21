require 'kari/ri/index'
require 'kari/ri/entry'

module Kari #:nodoc:
  # Holds all the classes and methods related to indexing and searching the RI YAML store.
  class RI
    class << self
      # Rebuilds, memoizes and returns the search index
      def index
        @index ||= Index.load
        @builder ||= Thread.new { @index = Index.rebuild; Thread.exit }
        @index
      end

      # Searches for matching entries in the RI database, returns those matches as Entry objects.
      def search(term)
        matches = index.find(term).map { |entry| Entry.new(entry, index) }
        matches.sort_by { |match| [match.name.length, match.name] }
      end

      # Searches for matching entries in the RI database, returns those matches as a Hash with two keys.
      # <code>:full_name</code> and <code>:definition_file</code>.
      def quick_search(term)
        matches = index.find(term)
        matches.sort_by { |match| match[:full_name].split('::').last.split('#').last.length }
      end

      # Returns the entry for the module, class or method with the specified name or nil if no match was found.
      def get(name)
        entry = index.get(name)
        entry ? Entry.new(entry, index) : nil
      end

      # Returns a string with the status of the indexining process.
      def status
        current_index = index
        return 'unknown' if @builder.nil?
        if @builder.status.nil?
          'failed'
        elsif @builder.status == false
          'ready'
        elsif @builder.status =~ /sleep|run/
          current_index.empty? ? 'building' : 'rebuilding'
        else
          @builder.status
        end
      end
    end
  end
end