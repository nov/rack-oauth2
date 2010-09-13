## OAuth 2.0 Web Server Flow

require 'rubygems'
require 'sinatra'

use Rack::Session::Cookie

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '../../../lib'))
require 'rack/oauth2/server'

use Rack::OAuth2::Server::Authorization do |request, response|
  # allow everything
  response.code = 'code'
  response.approved = request.params['approved']
  response
end

get '/oauth/authorize' do
  request = env['rack.oauth2.request']
  # output form
  <<-HTML
  <form action="/oauth/authorize" method="post">
    <input type="hidden" name="client_id" value="#{request.client_id}" />
    <input type="hidden" name="redirect_uri" value="#{request.redirect_uri}" />
    <input type="hidden" name="response_type" value="code" />
    <input type="hidden" name="approved" value="true" />
    <input type="submit" value="allow">
  </form>
  HTML
end

post '/oauth/authorize' do
end
