require 'kari/ri/index'
require 'kari/ri/entry'

module Kari #:nodoc:

  # The RI module holds all the classes and methods related to indexing and searching the RI YAML store.
  class RI
    INDEX = Index.rebuild

    class << self
      # Searches for matching entries in the RI database, returns those matches as Entry objects.
      def search(term)
        matches = INDEX.find(term).map { |entry| Entry.new(entry, INDEX) }
        matches.sort_by { |match| [match.name.length, match.name] }
      end

      # Searches for matching entries in the RI database, returns those matches as a Hash with two keys.
      # <code>:full_name</code> and <code>:definition_file</code>.
      def quick_search(term)
        matches = INDEX.find(term)
        matches.sort_by { |match| match[:full_name].split('::').last.split('#').last.length }
      end

      # Returns the entry for the module, class or method with the specified name or nil if no match was found.
      def get(name)
        entry = INDEX.get(name)
        entry ? Entry.new(entry, INDEX) : nil
      end

      # Returns a string with the status of the indexining process.
      def status
        if INDEX.nil?
          'indexing'
        elsif INDEX.kind_of?(Kari::RI::Index)
          'ready'
        else
          'indexing failed'
        end
      end
    end
  end
end