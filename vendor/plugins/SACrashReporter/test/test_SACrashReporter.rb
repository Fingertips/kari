require "rubygems"
require "test/unit"
require "test/spec"
require 'mocha'

$:.unshift File.expand_path('../../lib', __FILE__)
require "SACrashReporter"
require File.expand_path('../test_helper', __FILE__)
require File.expand_path('../SATestHelper', __FILE__)

def crash_log_path
  File.expand_path('../test.crash.log', __FILE__)
end

FRAME_HEIGHT = 200

describe 'SACrashReporter' do
  before(:each) do
    #SACrashReporter.class_eval { @@crash_log_path = nil }
    eval "class SACrashReporter; @@crash_log_path = nil; end"
  end
  
  it "should run the normal RubyCocoa init code" do
    SACrashReporter.expects(:rb_main_init).once
    OSX.expects(:NSApplicationMain).once
    SACrashReporter.run_app
  end
  
  it "should catch any exceptions raised during the execution of the app, create a report for the current app and re-raise the exception" do
    msg = 'Terrible Exception!'
    
    SACrashReporter.expects(:rb_main_init).once
    OSX.expects(:NSApplicationMain).raises(Exception, msg)
    
    report_mock = mock('Report Mock')
    report_mock.expects(:exception=)
    report_mock.expects(:message).returns(msg)
    SACrashReporter.expects(:report).times(2).returns(report_mock)
    
    file_mock = mock('Crash Log File')
    file_mock.expects(:write).with(msg)
    
    SACrashReporter.expects(:new_crash_log_path).returns(crash_log_path)
    File.expects(:open).with(crash_log_path, 'a').yields(file_mock)
    
    lambda { SACrashReporter.run_app }.should.raise(Exception)
  end
  
  it "should not create a crash report for a signal exception" do
    SACrashReporter.expects(:rb_main_init).once
    OSX.expects(:NSApplicationMain).raises(SignalException, 'SIGHUP')
    SACrashReporter.expects(:report).times(0)
    lambda { SACrashReporter.run_app }.should.raise(SignalException)
  end
  
  it "should work with one crash log file on 10.4" do
    OSX::NSBundle.mainBundle.expects(:infoDictionary).returns({'CFBundleExecutable' => 'MyApp'})
    SAFoundation::OS.expects(:os_version).returns('10.4.1')
    SACrashReporter.new_crash_log_path.should == File.expand_path("~/Library/Logs/CrashReporter/MyApp.crash.log")
  end
  
  LEOPARD_STYLE_CRASH_LOG_PATH = File.expand_path("~/Library/Logs/CrashReporter/MyApp_2007-01-02-030405_monkey-patch-HQ.crash")
  
  it "should work with multiple crash log files on 10.5" do
    OSX::NSBundle.mainBundle.expects(:infoDictionary).returns({'CFBundleExecutable' => 'MyApp'})
    
    SAFoundation::OS.expects(:os_version).returns('10.5.1')
    SAFoundation::OS.expects(:host_name).returns('monkey-patch-HQ.local')
    
    time_mock = mock('Time')
    Time.expects(:now).returns(time_mock)
    time_mock.expects(:year).returns(2007)
    time_mock.expects(:month).returns(1)
    time_mock.expects(:day).returns(2)
    time_mock.expects(:hour).returns(3)
    time_mock.expects(:min).returns(4)
    time_mock.expects(:sec).returns(5)
    
    SACrashReporter.new_crash_log_path.should == LEOPARD_STYLE_CRASH_LOG_PATH
  end
  
  it "should get the path to an existing crash log on 10.4" do
    SACrashReporter.expects(:app_name).returns('MyApp').at_least_once
    Dir.expects(:entries).returns(%w{ MyApp.crash.log foo.crash.log })
    SACrashReporter.crash_log_path.should == File.expand_path("~/Library/Logs/CrashReporter/MyApp.crash.log")
  end
  
  it "should get the path to an existing crash log on 10.5" do
    SACrashReporter.expects(:app_name).returns('MyApp').at_least_once
    Dir.expects(:entries).returns([File.basename(LEOPARD_STYLE_CRASH_LOG_PATH), 'MyApp.crash.log', 'foo.crash.log'])
    SACrashReporter.crash_log_path.should == LEOPARD_STYLE_CRASH_LOG_PATH
  end
  
  it "should create the crash reporter directory if it doesn't exist" do
    dir = File.expand_path("~/Library/Logs/CrashReporter")
    File.expects(:exist?).with(dir).returns(false)
    FileUtils.expects(:mkdir_p).with(dir)
    SACrashReporter.crash_log_path
  end
  
  it "should return the application name" do
    OSX::NSBundle.mainBundle.expects(:infoDictionary).returns({'CFBundleExecutable' => 'MyApp'})
    SACrashReporter.app_name.should == 'MyApp'
  end
  
  it "should return the developer name" do
    OSX::NSBundle.mainBundle.expects(:infoDictionary).returns({'SACrashReporterDeveloperName' => 'Santa Claus'})
    SACrashReporter.developer.should == 'Santa Claus'
  end
  
  it "should allow custom init code in a block" do
    self.expects(:foo_init_method)
    SACrashReporter.run_app do
      foo_init_method
    end
  end
  
  it "should allow report customization" do
    order_of_logs = [[:host_name], [:os_version, :pid]]
    SACrashReporter.configure do |report|
      report.order = order_of_logs
    end
    SACrashReporter.report.order.should.be order_of_logs
  end
  
  it "should allow a custom report subclass to be used" do
    SACrashReporter.configure :report_class => ReportSubclass do |report|
      report.should.be.an.instance_of ReportSubclass
      report.get(:crap).should == ['Crap:', 'crap!']
    end
  end
  
  it "should check if there's a new crash log and return false if no log file exists" do
    SACrashReporter.expects(:crash_log_path).returns(crash_log_path)
    File.expects(:exist?).with(crash_log_path).returns(false)
    SACrashReporter.new_crash_log_exists?.should.be false
  end
  
  it "should check if there's a new crash log" do
    SACrashReporter.expects(:crash_log_path).at_least_once.returns(crash_log_path)
    
    OSX::NSUserDefaults.standardUserDefaults.expects(:[]).with('SACrashReporterLastCheckSum').returns('f2a899e8b6f19ac0ab4a9dd13489e7b8334a4791')
    SACrashReporter.new_crash_log_exists?.should.be false
    
    OSX::NSUserDefaults.standardUserDefaults.expects(:[]).with('SACrashReporterLastCheckSum').returns('definitely not the same...')
    SACrashReporter.new_crash_log_exists?.should.be true
  end
  
  it "should get the crash log data" do
    SACrashReporter.expects(:crash_log_path).returns(crash_log_path)
    SACrashReporter.crash_log_data.should == "FooBar"
  end
  
  it "should check if there's a new crash log and start the submit process" do
    SACrashReporter.expects(:new_crash_log_exists?).returns(true)
    
    controller_mock = mock('SACrashReporter controller')
    controller_mock.expects(:showWindow).with(SACrashReporter)
    SACrashReporter.expects_alloc_init_returns(controller_mock)
    
    OSX::NSUserDefaults.standardUserDefaults.expects(:[]=).with('SACrashReporterLastCheckSum', 'f2a899e8b6f19ac0ab4a9dd13489e7b8334a4791')
    OSX::NSUserDefaults.standardUserDefaults.expects(:[]).with('SACrashReporterInitialized').returns(true)
    
    OSX::NSUserDefaults.standardUserDefaults.expects(:synchronize)
    
    SACrashReporter.submit
  end
  
  it "should not report a crash log if it's the first time ever that the crash reporter is ran" do
    OSX::NSUserDefaults.standardUserDefaults.expects(:[]).with('SACrashReporterInitialized').returns(nil)
    OSX::NSUserDefaults.standardUserDefaults.expects(:[]=).with('SACrashReporterInitialized', true)
    
    SACrashReporter.expects(:new_crash_log_exists?).returns(true)
    
    SACrashReporter.expects(:crash_log_checksum).returns('bla')
    OSX::NSUserDefaults.standardUserDefaults.expects(:[]=).with('SACrashReporterLastCheckSum', 'bla')
    
    OSX::NSUserDefaults.standardUserDefaults.expects(:synchronize)
    
    SACrashReporter.submit
  end
end

describe 'SACrashReporter', "when it's initialized" do
  before do
    window_mock = mock("Window")
    @reporter = SACrashReporter.alloc.init
    @reporter.stubs(:window).returns(window_mock)
  end
  
  it "should set the window title for this application" do
    SACrashReporter.expects(:app_name).returns('Foo')
    @reporter.window.expects(:title=).with('Problem Report for Foo')
    @reporter.set_title_for_app
  end
  
  it "should set the name of the developer in the footnote text" do
    SACrashReporter.expects(:developer).returns('Santa Claus')
    @reporter.ivar(:@footnoteTextfield).expects(:stringValue=).with("Your response will help Santa Claus improve this software. Your personal information will not be sent with this report, and you will not be contacted unless you request it.")
    @reporter.set_footnote_text_with_dev
  end
  
  it "should set the name of the developer in the button text" do
    SACrashReporter.expects(:developer).returns('Santa Claus')
    @reporter.ivar(:@sendReportButton).expects(:title=).with('Send to Santa Claus...')
    @reporter.set_button_text_with_dev
  end
  
  it "should set the window title, the developer name and add the last crash log data to the textfield" do
    @reporter.expects(:set_title_for_app)
    @reporter.expects(:set_footnote_text_with_dev)
    @reporter.expects(:set_button_text_with_dev)
    
    crash_log_data = 'FooBar'
    SACrashReporter.expects(:crash_log_data).returns(crash_log_data)
    @reporter.ivar(:@crashLogDataTextfield).expects(:string=).with(crash_log_data)
    
    @reporter.windowDidLoad
  end
  
  it "should send the report by HTTP Post" do
    @reporter.ib_outlet(:statusSpinner).expects(:startAnimation).with(@reporter)
    @reporter.ib_outlet(:statusTextField).expects(:hidden=).with(false)
    
    OSX::NSBundle.mainBundle.stubs(:infoDictionary).returns({'SACrashReporterPostURL' => 'http://www.example.com/crash_report.php', 'CFBundleExecutable' => 'MyApp'})
    SACrashReporter.expects(:crash_log_data).returns('FooBar')
    @reporter.ib_outlet(:commentTextfield).expects(:string).returns('blah')
    
    params_mock = mock('Params')
    OSX::NSString.expects(:stringWithString).with('crash_log=FooBar&app_name=MyApp&comment=blah').returns(params_mock)
    params_mock.expects(:dataUsingEncoding).with(OSX::NSASCIIStringEncoding)
    
    str_url = 'http://www.example.com/crash_report.php'
    url_mock = mock("NSURL mock")
    OSX::NSURL.expects(:URLWithString).with(str_url).returns(url_mock)
    
    request_mock = mock("NSMutableURLRequest mock")
    OSX::NSMutableURLRequest.expects(:requestWithURL_cachePolicy_timeoutInterval).with(url_mock, OSX::NSURLRequestUseProtocolCachePolicy, 30.0).returns(request_mock)
    request_mock.expects(:setHTTPMethod).with('POST')
    request_mock.expects(:setHTTPBody)
    
    connection_mock = mock('NSURLConnection mock')
    OSX::NSURLConnection.expects(:alloc).returns(connection_mock)
    connection_mock.expects(:initWithRequest_delegate).with(request_mock, @reporter)
    
    @reporter.sendReport(nil)
  end
  
  it "should close the window once the connection has finished, with or without errors" do
    @reporter.expects(:close).times(2)
    @reporter.connectionDidFinishLoading(nil)
    @reporter.connection_didFailWithError(nil, nil)
  end
  
  it "should expand the crash information textfield when clicking the expansion triangle and it is not already expanded" do
    origin_mock = mock('crashLogWindowFrameOrigin')
    frame = OSX::NSRect.new(0, 0, 300, FRAME_HEIGHT)
    minSize = OSX::NSSize.new(608, 370)
    @reporter.ib_outlet(:crashLogWindow).expects(:frame).returns(frame)
    @reporter.ib_outlet(:crashLogWindow).expects(:minSize).at_least_once.returns(minSize)
    @reporter.ib_outlet(:crashLogWindow).expects(:setFrame_display_animate).with(frame, true, true)
    @reporter.ib_outlet(:crashLogWindow).expects(:setMinSize).with do |size|
      size.width == minSize.width && size.height == minSize.height + SACrashReporter::WINDOW_EXPANSION_AMOUNT
    end
    @reporter.toggleExpansion
    frame.origin.y.should == -SACrashReporter::WINDOW_EXPANSION_AMOUNT.to_f
    frame.size.height.should == (FRAME_HEIGHT + SACrashReporter::WINDOW_EXPANSION_AMOUNT).to_f
  end

  it "should retract the crash information textfield when clicking the expansion triangle and it is already expanded" do
    origin_mock = mock('crashLogWindowFrameOrigin')
    @reporter.isExpanded = true
    frame = OSX::NSRect.new(0, -SACrashReporter::WINDOW_EXPANSION_AMOUNT, 300, FRAME_HEIGHT + SACrashReporter::WINDOW_EXPANSION_AMOUNT)
    minSize = OSX::NSSize.new(608, 370)
    @reporter.ib_outlet(:crashLogWindow).expects(:frame).returns(frame)
    @reporter.ib_outlet(:crashLogWindow).expects(:minSize).at_least_once.returns(minSize)
    @reporter.ib_outlet(:crashLogWindow).expects(:setFrame_display_animate).with(frame, true, true)
    @reporter.ib_outlet(:crashLogWindow).expects(:setMinSize).with do |size|
      size.width == minSize.width && size.height == minSize.height - SACrashReporter::WINDOW_EXPANSION_AMOUNT
    end
    @reporter.toggleExpansion
    frame.origin.y.should == 0
    frame.size.height.should == FRAME_HEIGHT.to_f
  end
end