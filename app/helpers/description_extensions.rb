module DescriptionExtensions
  def separator
    case full_name
    when /\#/
      '#'
    when /\./
      '.'
    else
      '::'
    end
  end
  
  def path
    RubyName.split(full_name)[0..-2].join('::')
  end
  
  def ri_type
    self.class.to_s =~ /^RI::(.*)Description$/ ? $1 : 'Module'
  end
  
  def template_name
    ri_type.downcase
  end
  
  def type
    @is_singleton ? 'ClassMethod' : ri_type
  end
end