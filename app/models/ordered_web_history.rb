class OrderedWebHistory < WebHistory
  def last
    if last_day = orderedLastVisitedDays.first
      orderedItemsLastVisitedOnDay(last_day).first
    end
  end
  
  def allItems
    orderedLastVisitedDays.collect{ |day| orderedItemsLastVisitedOnDay(day).to_a }.flatten.reverse
  end
end