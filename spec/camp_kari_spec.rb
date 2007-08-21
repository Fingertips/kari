require File.dirname(File.expand_path(__FILE__)) + "/../Backend.rb"

describe Backend do
  it "should start the backend in a separate process" do
    backend = Backend.new
    
    backend.launch
    backend.should be_running
    
    backend.terminate
    sleep 2
    backend.should_not be_running
  end
end