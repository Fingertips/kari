class Test::Unit::TestCase
  def assert_difference(eval_str, difference)
    before = eval(eval_str)
    yield
    assert_equal(before + difference, eval(eval_str))
  end
  
  def assert_no_difference(eval_str)
    assert_difference(eval_str, 0) do
      yield
    end
  end
end