require File.dirname(File.expand_path(__FILE__)) + "/../CampKari.rb"

describe CampKari do
  it "should start the backend in a separate process" do
    camp_kari = CampKari.alloc.init
    
    camp_kari.launch
    camp_kari.should be_running
    
    camp_kari.terminate
    sleep 2
    camp_kari.should_not be_running
  end
end