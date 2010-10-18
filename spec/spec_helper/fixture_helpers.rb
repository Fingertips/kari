module FixtureHelpers
  def file_fixture(*parts)
    File.join(TEST_ROOT_PATH, 'fixtures', *parts)
  end
end