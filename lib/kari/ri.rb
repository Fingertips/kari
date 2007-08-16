require 'kari/ri/index'
require 'kari/ri/match'

module Kari #:nodoc:
  
  # The RI module holds all the classes and methods related to indexing and searching the RI YAML store.
  module RI
    
    # Searches for matching entries in the RI database, returns those matches as Match objects.
    def search(term)
      index = Index.load
      index.find(term).map { |entry| Match.new(entry, index) }
    end
    module_function :search
  end
end