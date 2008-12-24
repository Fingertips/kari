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
    when SM::Flow::P
      content_tag('p', part.body)
    when SM::Flow::LI
      content_tag('li', part.body)
    when SM::Flow::LIST
      flow_list(part)
    when SM::Flow::VERB
      content_tag('pre', part.body)
    when SM::Flow::H
      "<h#{part.level+2}>#{h(part.text)}</h#{part.level+2}>"
    when SM::Flow::RULE
      "<hr />"
    end
  end
end