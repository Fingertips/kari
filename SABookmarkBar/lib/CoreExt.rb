class Array
  def switch(idx1, idx2)
    self_dup = self.dup
    self_dup[idx1], self_dup[idx2] = self_dup.values_at(idx2, idx1)
    return self_dup
  end
  def move(from, to)
    self_dup = self.dup
    self_dup = self_dup.insert(to, self_dup.delete_at(from))
    self_dup.each_with_index {|bookmark, index| bookmark.order_index = index }
    return self_dup
  end
end