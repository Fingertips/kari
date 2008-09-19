class String
  unless '>= 1.8.7'.respond_to?(:start_with?)
    # Returns true when the string starts with the specified prefix
    def start_with?(prefix)
      prefix = prefix.to_s
      self[0, prefix.length] == prefix
    end
    
    # Returns true when the string ends with the specified suffix
    def end_with?(suffix)
      suffix = suffix.to_s
      self[-suffix.length, suffix.length] == suffix
    end
  end
  
  # Returns true when the string is blank
  def blank?
    self == ''
  end
end
