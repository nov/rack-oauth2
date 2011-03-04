$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'rack/oauth2'
require 'rspec'

def simple_app
  lambda do |env|
    [ 200, {'Content-Type' => 'text/plain'}, ["HELLO"] ]
  end
end