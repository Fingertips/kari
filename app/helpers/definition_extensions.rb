module DefinitionExtensions
  def separator
    if full_name =~ /#/
      '#'
    elsif full_name =~ /\./
      '.'
    else
      '::'
    end
  end
  
  def path
    full_name.split(/::|#|\./)[0..-2].join('::')
  end
  
  def ri_type
    if self.class.to_s =~ /^RI::(.*)Description$/
      $1
    else
      'Module'
    end 
  end
  
  def template_name
    ri_type.downcase
  end
  
  def type
    @is_singleton ? 'ClassMethod' : ri_type
  end
end