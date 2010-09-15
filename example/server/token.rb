require 'rubygems'
require 'sinatra'

use Rack::Session::Cookie

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '../../lib'))
require 'rack/oauth2'

use Rack::OAuth2::Server::Token do |request, response|
  # allow everything
  response.access_token = 'access_token'
  response.expires_in = 3600
  response.refresh_token = 'refresh_token'
end

get '/oauth/token' do
end

post '/oauth/token' do
end