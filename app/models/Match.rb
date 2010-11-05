class Match
  def name
    @name ||= RubyName.from_karidoc_path(URL().path)
  end
  
  def filename
    NSURL.fileURLWithPath(File.join(Manager.current_filepath, URL().path))
  end
  
  def inspect
    "#<SearchKit::Match:#{object_id} name=#{name} url=#{URL().path} score=#{score}>"
  end
end