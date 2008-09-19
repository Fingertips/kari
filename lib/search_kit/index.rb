module SearchKit #:nodoc:
  # SearchKit::Index is a wrapper around a OSX::SKIndex. It indexes documents which can then be
  # queried.
  class Index < OSX::NSObject
    # Creates a new index on disk
    #
    # * _path_: Path to the index
    # * _name_: Allows you to store multiple indexes in one file (use +nil+ to store just one
    #   index in the file)
    # * _type_: The type of index you want to build. Defaults to an inverted index
    #
    # Examples:
    #
    #   SearchKit::Index.create(File.expand_path('~/.address_book_index'))
    #   SearchKit::Index.create(File.expand_path('~/.visualizer/indices'), 'nodes')
    def self.create(path, name=nil, type=OSX::KSKIndexInverted)
      alloc.initWithIndex(OSX::SKIndexCreateWithURL(OSX::NSURL.fileURLWithPath(path), name, type, nil))
    end
    
    # Open an index from disk
    #
    # * _path_: Path to the file holding the index
    # * _name_: Open a specific index in the file, leave nil if the file just contains one index
    # * _allow_updating_: Set to true if you want to add new documents to the index
    #
    # Examples:
    #
    #   index = SearchKit::Index.open(File.expand_path('~/.address_book_index'), true)
    #   index.addDocument(filename)
    #   index.close
    #
    #   SearchKit::Index.open(File.expand_path('~/.visualizer/indices'), 'nodes', true) do |index|
    #     index.addDocument(filename)
    #   end
    def self.open(path, name=nil, allow_updating=false, &block)
      index = alloc.initWithIndex(OSX::SKIndexOpenWithURL(OSX::NSURL.fileURLWithPath(path), name, allow_updating))
      if block
        begin
          yield index
        ensure
          index.close
        end
      else
        index
      end
    end
    
    # Initialize an Index instance with an already open SKIndex.
    #
    # You probably want to use SearchKit::Index.open or SearchKit::Index.create instead of this
    # method.
    def initWithIndex(index)
      if init
        @index = index
        self
      end
    end
    
    # Close the index. You should always close the index after using it to free up memory and
    # locks.
    def close
      OSX::SKIndexClose(@index)
    end
    
    # Add a document with a certain path to the index.
    #
    # * _path_: Path to the file to index
    # * _mime_type_hint_: Tell the indexer which SpotLight importer to use for indexing this
    #   document
    #
    # Make sure you specify +allow_updating+ when opening the index, otherwise you will not be able
    # to change it.
    #
    # Example:
    #
    #   index = SearchKit::Index.open(File.expand_path('~/.address_book_index'), true)
    #   index.addDocument(filename)
    #   index.close
    def addDocument(path, mime_type_hint=nil)
      url = OSX::NSURL.fileURLWithPath(path)
      document = OSX::SKDocumentCreateWithURL(url)
      # FIXME: the third param is a MIMETypeHint that is used to select a SpotLight importer
      OSX::SKIndexAddDocument(@index, document, nil, true)
    end
    
    # Remove a document with a certain path from the index.
    #
    # * _path_: Path to the document to remove from the index
    #
    # Example:
    #
    #   index = SearchKit::Index.open(File.expand_path('~/.address_book_index'), true)
    #   index.removeDocument(filename)
    #   index.close
    def removeDocument(path)
      url = OSX::NSURL.fileURLWithPath(path)
      document = OSX::SKDocumentCreateWithURL(url)
      # FIXME: the third param is a MIMETypeHint that is used to select a SpotLight importer
      OSX::SKIndexRemoveDocument(@index, document)
    end
    
    # Returns the number of documents in the index
    def count
      if (count = OSX::SKIndexGetDocumentCount(@index)) != 0
        count - 9
      else
        raise SearchKit::Exceptions::IndexError, "Can't perform OSX::SKIndexGetDocumentCount on the index `#{@index}'. Please make sure you're operating on a valid index."
      end
    end
    
    # Commit all the index changes to the backing store
    def flush
      OSX::SKIndexFlush(@index)
    end
    
    # Compacts the index by removing orphaned terms. This a rather expensive operation, so you
    # don't want to call it after every index update.
    def compact
      OSX::SKIndexCompact(@index)
    end
  end
end