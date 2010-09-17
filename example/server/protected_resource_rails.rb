# in environment.rb
Rails::Initializer.run do |config|
  :
  require 'rack/oauth2'
  oauth2_authenticator = lambda do |request|
    access_token = Oauth2::AccessToken.find_by_token(request.access_token)
    if access_token.blank?
      raise Rack::OAuth2::Server::Unauthorized.new(:invalid_token, "Given access token is invalid.", :www_authenticate => true)
    elsif access_token.expired?
      raise Rack::OAuth2::Server::Unauthorized.new(:expired_token, "Given access token has been expired.", :www_authenticate => true)
    elsif access_token.revoked?
      raise Rack::OAuth2::Server::Unauthorized.new(:invalid_token, "Given access token has been revoked.", :www_authenticate => true)
    end
  end
  config.middleware.insert_before(RestfulJsonpMiddleware, Rack::OAuth2::Server::Resource, "server.example.com", &oauth2_authenticator)
  :
end