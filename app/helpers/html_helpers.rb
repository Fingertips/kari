require 'erb'

module HTMLHelpers
  include ERB::Util
  
  def tag_attributes(attributes={})
    return '' if attributes.empty?
    ' ' << attributes.inject([]) do |attrs, (k, v)|
      attrs << "#{k}=\"#{html_escape(v)}\""
    end.join(' ')
  end
  
  def content_tag(name, contents="", attributes={}, &block)
    contents = yield if block
    "<#{name}#{tag_attributes(attributes)}>#{contents}</#{name}>"
  end
  
  def header_with_markup(path, separator, name)
    header = []
    unless path.empty?
      header.concat [
        content_tag('span', h(path), :class => 'path'),
        content_tag('span', h(separator))
      ]
    end
    header << content_tag('span', h(name), :class => 'name')
    header.join
  end
  
  def render_description(description)
    assign :description, description
    partials[description.template_name].result(binding)
  end
  
  def classes_for(description, descriptions)
    [description.template_name, (description == descriptions.first) ? 'primary' : 'secondary'].compact.join(' ')
  end
end