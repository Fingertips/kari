module HTMLHelpers
  include ERB::Util

  def tag_attributes(options)
    attrs = options.inject([]) do |attrs, (k, v)|
      attrs << "#{k}=\"#{v}\""
    end
    attrs.empty? ? '' : " #{attrs.join(' ')}"
  end

  def content_tag(name, contents="", options={}, &block)
    contents = yield if block
    "<#{name}#{tag_attributes(options)}>#{contents}</#{name}>"
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