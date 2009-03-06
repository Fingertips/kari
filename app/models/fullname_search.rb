module FullnameSearch
  def self.search(query, descriptions)
    matches = []
    descriptions.each do |fullname, _|
      if m = match(query, fullname)
        matches << m
      end
    end
    matches
  end
  
  def self.match(query, fullname)
    eoq = false
    
    accumulator = ''
    marked_fullname = ''
    in_marked = true
    
    query_cursor = 0
    fullname_cursor = 0
    
    query_downcased = query.downcase
    fullname_downcased = fullname.downcase
    
    while(!eoq)
      if fullname_downcased[fullname_cursor] == query_downcased[query_cursor]
        if !in_marked
          marked_fullname << accumulator
          accumulator = ''
        end
        in_marked = true
        query_cursor += 1
      else
        if in_marked
          marked_fullname << '<strong>'
          marked_fullname << accumulator
          marked_fullname << '</strong>'
          accumulator = ''
        end
        in_marked = false
      end
      accumulator << fullname[fullname_cursor..fullname_cursor]
      
      fullname_cursor += 1
      
      if query_cursor > query.length or fullname_cursor > fullname.length
        eoq = true
      end
    end
    
    if query_cursor > query.length
      [fullname, marked_fullname]
    else
      false
    end
  end
end