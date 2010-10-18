module StringExtensions
  # Returns true when the string is blank
  def blank?
    empty?
  end
end

class String
  include StringExtensions
end