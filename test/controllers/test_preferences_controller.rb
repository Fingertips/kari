require File.expand_path('../../test_helper', __FILE__)

xdescribe 'PreferencesController' do
  include GlobalSpecHelper
  
  before do
    @controller = PreferencesController.alloc.init
    
    # If this is a window controller belonging to a document model,
    # then this will allow you to mock the document.
    #
    # @document = mock('Document')
    # @controller.stubs(:document).returns(@document)
  end
  
  it "should return a predefined list of bookmarks if there's no preference file yet and store it in the preferences" do
    prefs = ['Foo', 'Bar']
    silence_warnings { PreferencesController::DEFAULT_BOOKMARKS = prefs }
    
    PreferencesController.registerDefaults
    PreferencesController.preferences['Bookmarks'].should == make_hashes(prefs).to_ns
  end
end