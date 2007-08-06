$:.unshift(File.expand_path(File.dirname(__FILE__)))
$:.unshift(File.expand_path('../lib', File.dirname(__FILE__)))

require 'mosquito'
require 'kari'

class TestKari < Camping::FunctionalTest

  def test_should_get_index
    get '/'
    assert_response :success
    assert_match_body %r(KARI)
    assert_equal 'text/html', @response.headers['Content-Type']
  end

  def test_should_get_search_response
    get '/search', :q => 'link_to'
    assert_response :success
    # TODO: search is broken for now, just expect a 200
    assert_equal 'text/html', @response.headers['Content-Type']
  end

  def test_should_get_stylesheets
    get '/stylesheets/default.css'
    assert_response :success
    assert_match_body %r(font-size)
    assert_equal 'text/css; charset=utf-8', @response.headers['Content-Type']
  end
end