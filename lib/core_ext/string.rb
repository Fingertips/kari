class String
  unless '>= 1.8.7'.respond_to?(:start_with?)
    def start_with?(prefix)
      prefix = prefix.to_s
      self[0, prefix.length] == prefix
    end
    
    def end_with?(suffix)
      suffix = suffix.to_s
      self[-suffix.length, suffix.length] == suffix
    end
  end
end
