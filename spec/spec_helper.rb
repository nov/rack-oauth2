$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'rack/oauth2'
require 'rspec/core'
require 'rack/mock'

def simple_app
  lambda do |env|
    [ 200, {'Content-Type' => 'text/plain'}, ["HELLO"] ]
  end
end

def assert_error_response(format, error)
  response = yield
  case format
  when :json
    response.status.should == 400
    response.body.should match("\"error\":\"#{error}\"")
  when :query
    response.status.should == 302
    response.location.should match("error=#{error}")
  end
end