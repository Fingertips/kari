$:.unshift(File.expand_path(File.dirname(__FILE__)))
$:.unshift(File.expand_path('../lib', File.dirname(__FILE__)))

ENV['KARI_HOME'] = File.expand_path('fixtures', File.dirname(__FILE__))
ENV['KARI_RI_PATH'] = File.expand_path('fixtures/ri', File.dirname(__FILE__))

require 'mosquito'
require 'kari'

require 'rubygems' rescue LoadError
require 'mocha'

class TestKari < Camping::FunctionalTest

  def test_should_get_index
    get '/'
    assert_response :success
    assert_match_body %r(KARI)
    assert_equal 'text/html', @response.headers['Content-Type']
  end

  def test_should_get_search_response
    get '/search', :q => 'square'
    assert_response :success
    assert_match_body %r(body)
    assert_equal 'text/html', @response.headers['Content-Type']
  end

  def test_should_get_stylesheets
    get '/stylesheets/default.css'
    assert_response :success
    assert_match_body %r(font-size)
    assert_equal 'text/css; charset=utf-8', @response.headers['Content-Type']
  end

  def test_should_get_javascripts
    get '/javascripts/error.js'
    assert_response :success
    assert_match_body %r(Error)
    assert_equal 'text/javascript; charset=utf-8', @response.headers['Content-Type']
  end

  def test_should_show_entry
    get '/show/Geometry'
    assert_response :success
    assert_match_body %r(body)
    assert_equal 'text/html', @response.headers['Content-Type']
  end
end