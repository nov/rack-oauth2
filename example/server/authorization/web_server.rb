## OAuth 2.0 Web Server Flow

require 'rubygems'
require 'sinatra'

use Rack::Session::Cookie

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '../../../lib'))
require 'rack/oauth2/server'

use Rack::OAuth2::Server::Authorization do |request, response|
  # allow everything
  response.code = 'code'
  response
end

get '/oauth/authorize' do
  params = request.env['rack.request.query_hash']
  # output form
  <<-HTML
  <form action="/oauth/authorize" method="post">
    <input type="hidden" name="client_id" value="#{params['client_id']}" />
    <input type="hidden" name="redirect_uri" value="#{params['redirect_uri']}" />
    <input type="hidden" name="response_type" value="#{params['response_type']}" />
    <input type="submit" value="allow">
  </form>
  HTML
end

post '/oauth/authorize' do
  
end