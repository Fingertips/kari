require File.dirname(File.expand_path(__FILE__)) + "/../Backend.rb"

class Backend
  def self.setTheReturnMock(mock)
    @theReturnMock = mock
  end
  def init
    @theReturnMock
  end
end

# describe Backend do
#   it "should start the backend in a separate process" do
#     backend_mock = mock("Backend")
#     backend_mock.stub!(:launch)
#     Backend.setTheReturnMock(backend_mock)
#     
#     backend = Backend.alloc.init
#     
#     backend.launch
#     backend.should be_running
#     
#     backend.terminate
#     sleep 2
#     backend.should_not be_running
#   end
# end