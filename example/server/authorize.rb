require 'rubygems'
require 'sinatra'

use Rack::Session::Cookie

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '../../lib'))
require 'rack/oauth2'

get '/oauth/authorize' do
  # set realm as server.example.com
  authorization_endpoint = Rack::OAuth2::Server::Authorize.new("server.example.com")
  response = authorization_endpoint.call(env)
  case response.first
  when 200
    request = env['rack.oauth2.request']
    # output form
    <<-HTML
    <form action="/oauth/authorize" method="post">
      <input type="hidden" name="client_id" value="#{request.client_id}" />
      <input type="hidden" name="redirect_uri" value="#{request.redirect_uri}" />
      <input type="hidden" name="response_type" value="#{request.response_type}" />
      <input type="hidden" name="approved" value="true" />
      <input type="submit" value="allow">
    </form>
    <form action="/oauth/authorize" method="post">
      <input type="hidden" name="client_id" value="#{request.client_id}" />
      <input type="hidden" name="redirect_uri" value="#{request.redirect_uri}" />
      <input type="hidden" name="response_type" value="#{request.response_type}" />
      <input type="hidden" name="response_type" value="code" />
      <input type="submit" value="deny">
    </form>
    HTML
  else
    # redirect response with error message
    response
  end
end

post '/oauth/authorize' do
  # set realm as server.example.com
  authorization_endpoint = Rack::OAuth2::Server::Authorize.new("server.example.com") do |request, response|
    params = env['rack.request.form_hash']
    if params['approved']
      response.approve!
      case request.response_type
      when :code
        response.code = 'code'
      when :token
        response.access_token = 'access_token'
        response.expires_in = 3600
      end
    else
      raise Rack::OAuth2::Server::Unauthorized.new(:access_denied, 'User rejected the requested access.', :redirect_uri => request.redirect_uri, :state => request.state)
    end
  end
  authorization_endpoint.call(env)
end