class AssertDifferenceAssertions
  def assert_difference(eval_str, difference)
    before = eval(eval_str)
    yield
    eval(eval_str).should == before + difference
  end
  
  def assert_no_difference(eval_str)
    assert_difference(eval_str, 0) do
      yield
    end
  end
end