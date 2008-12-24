require 'rubygems'
require "test/unit"
require "test/spec"
require 'mocha'

$:.unshift File.expand_path('../../lib', __FILE__)
require "Report"
require File.expand_path('../test_helper', __FILE__)

require 'osx/cocoa'

describe 'SACrashReporter::Report' do
  before do
    @report = SACrashReporter::Report.new
  end
  
  it "should return the machines hostname" do
    @report.get(:host_name).should == ['Host Name:', `hostname`.chomp]
  end
  
  it "should return the date/time" do
    @report.get(:date_time).should == ['Date/Time:', Time.now.to_s]
  end
  
  it "should return the os version" do
    SAFoundation::OS.expects(:os_version_and_build).times(2).returns(['10.4.10', '8R2232'])
    @report.get(:os_version).should == ['OS Version:', '10.4.10 (8R2232)']
  end
  
  it "should return the report version" do
    @report.get(:report_version).should == ['Report Version:', "SACrashReporter version 1.2"]
  end
  
  it "should return the executable command" do
    OSX::NSBundle.mainBundle.expects(:infoDictionary).returns({'CFBundleExecutable' => 'Foo'})
    @report.get(:command).should == ['Command:', 'Foo']
  end
  
  it "should return the path to the executable" do
    path = '/Applications/Foo.app/Contents/MacOS/Foo'
    path_mock = mock()
    path_mock.expects(:fileSystemRepresentation).returns(path)
    OSX::NSBundle.mainBundle.expects(:executablePath).returns(path_mock)
    @report.get(:path).should == ['Path:', path]
  end
  
  it "should return the app short version and version" do
    short_version = '1.0 final'
    version = 1.0
    OSX::NSBundle.mainBundle.expects(:infoDictionary).returns({'CFBundleShortVersionString' => short_version, 'CFBundleVersion' => version})
    @report.get(:version).should == ['Version:', "#{short_version} (#{version})"]
  end
  
  it "should return the apps PID" do
    pid = 10999
    OSX::NSProcessInfo.processInfo.expects(:processIdentifier).returns(pid)
    @report.get(:pid).should == ['PID:', pid.to_s]
  end
  
  it "should return a apple style crash message if no options are specified" do
    DEFAULT_APPLE_STYLE_CRASH_VALUES.each do |key, value|
      @report.expects(key).returns(value)
    end
    @report.exception = BACKTRACE_MOCK
    @report.message.should == DEFAULT_APPLE_STYLE_CRASH_MESSAGE
  end
  
  it "should be possible to alter the order and selection of the various logs" do
    @report.expects(:pid).returns(DEFAULT_APPLE_STYLE_CRASH_VALUES[:pid])
    @report.expects(:os_version).returns(DEFAULT_APPLE_STYLE_CRASH_VALUES[:os_version])
    @report.expects(:error_and_bt).returns('')
    @report.order = [:host_name], [:os_version, :pid]
    @report.message.should == CUSTOM_ORDER_AND_SELECTION_MESSAGE
  end
  
  it "should be possible to create a Report subclass" do
    report = ReportSubclass.new
    report.expects(:os_version).returns(DEFAULT_APPLE_STYLE_CRASH_VALUES[:os_version])
    report.expects(:error_and_bt).returns('')
    report.order = [:crap], [:os_version, :even_more_crap]
    report.message.should == CUSTOM_LOGS_MESSAGE
  end
end
