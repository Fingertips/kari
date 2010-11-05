require File.expand_path('../../spec_helper', __FILE__)

describe "Match" do
  before do
    @url   = NSURL.fileURLWithPath(File.join('', 'Mutex', 'try_lock.karidoc'))
    @score = 1.2345
    @match = Match.alloc.initWithURL(@url, score: @score)
  end
  
  it "has all necessary properties" do
    @match.URL.should == @url
    @match.score.should == @score
  end
  
  it "figures out its name from the karidoc path" do
    @match.name.should == 'Mutex::try_lock'
  end
  
  it "figures out its filename from the karidoc path" do
    @match.filename.absoluteString.end_with?('Mutex/try_lock.karidoc').should == true
  end
end