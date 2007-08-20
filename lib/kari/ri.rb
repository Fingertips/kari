require 'kari/ri/index'
require 'kari/ri/entry'

module Kari #:nodoc:
  
  # The RI module holds all the classes and methods related to indexing and searching the RI YAML store.
  module RI
    Index.build
    INDEX = Index.load
    
    module_function
    
    # Searches for matching entries in the RI database, returns those matches as Entry objects.
    def search(term)
      matches = INDEX.find(term).map { |entry| Entry.new(entry, INDEX) }
      matches.sort_by { |match| [match.name.length, match.name] }
    end
    
    # Returns the entry for the module, class or method with the specified name or nil if no match was found.
    def get(name)
      entry = INDEX.get(name)
      entry ? Entry.new(entry, INDEX) : nil
    end
  end
end