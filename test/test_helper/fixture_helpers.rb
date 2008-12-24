module FixtureHelpers
  def file_fixture(*parts)
    File.join(TEST_ROOT, 'fixtures', *parts)
  end
end