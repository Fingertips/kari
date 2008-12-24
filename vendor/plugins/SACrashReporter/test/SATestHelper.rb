require 'osx/cocoa'

module OSX
  # Allows methods to be overriden with a different arity.
  #
  # TODO: Check with Laurent if this is bad?
  # Otherwise we should maybe override the stub method to set this to true
  # when the object is a subclass of OSX::NSObject and set it to false again after the stubbing.
  def self._ignore_ns_override; true; end

  # A Mocha helper method which allows to stub alloc.init and return a mock.
  #
  #   it "should init and return an instance" do
  #     obj_mock = mock("NSObject mock")
  #     OSX::NSObject.expects_alloc_init_returns(obj_mock) # performs 2 assertions
  #     OSX::NSObject.alloc.init.should == obj_mock
  #   end
  #
  # Results in:
  # 1 tests, 3 assertions, 0 failures, 0 errors
  class NSObject
    def self.expects_alloc_init_returns(mock)
      mock.expects(:init).returns(mock)
      self.expects(:alloc).returns(mock)
    end
  end
end