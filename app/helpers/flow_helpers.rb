module FlowHelpers
  def flow(flow)
    flow.inject('') do |out, part|
      out << flow_part(part)
    end
  end
  
  def flow_list(list)
    # TODO: better support for the various list types
    content_tag('ul') do
      list.contents.inject('') do |out, item|
        out << flow_part(item)
      end
    end
  end
  
  def flow_part(part)
    case part
    when RDoc::Markup::Flow::P
      content_tag('p', part.body)
    when RDoc::Markup::Flow::LI
      content_tag('li', part.body)
    when RDoc::Markup::Flow::LIST
      flow_list(part)
    when RDoc::Markup::Flow::VERB
      content_tag('pre', part.body)
    when RDoc::Markup::Flow::H
      "<h#{part.level+2}>#{h(part.text)}</h#{part.level+2}>"
    when RDoc::Markup::Flow::RULE
      "<hr />"
    else
      ''
    end
  end
end