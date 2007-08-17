require 'kari/ri/index'
require 'kari/ri/entry'

module Kari #:nodoc:
  
  # The RI module holds all the classes and methods related to indexing and searching the RI YAML store.
  module RI
    
    module_function
    
    # Searches for matching entries in the RI database, returns those matches as Entry objects.
    def search(term)
      index = Index.load
      matches = index.find(term).map { |entry| Entry.new(entry, index) }
      matches.sort_by { |match| [match.name.length, match.name] }
    end
    
    # Returns the entry for the module, class or method with the specified name or nil if no match was found.
    def get(name)
      index = Index.load
      entry = index.get(name)
      entry ? Entry.new(entry, index) : nil
    end
  end
end