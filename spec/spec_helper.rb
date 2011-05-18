require 'rack/oauth2'
require 'rspec'
require 'fakeweb'
require 'helpers/time'

def simple_app
  lambda do |env|
    [ 200, {'Content-Type' => 'text/plain'}, ["HELLO"] ]
  end
end

def fake_response(method, endpoint, file_path, options = {})
  FakeWeb.register_uri(
    method,
    endpoint,
    options.merge(
      :body => File.read(
        File.join(File.dirname(__FILE__), 'fake_response', file_path)
      )
    )
  )
end
FakeWeb.allow_net_connect = false