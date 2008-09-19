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
    [
      content_tag('span', h(path), :class => 'path'),
      content_tag('span', h(separator)),
      content_tag('span', h(name), :class => 'name')
    ].join
  end
  
  def render_definition(definition)
    assign :definition, definition
    partials[definition.template_name].result(binding)
  end
end