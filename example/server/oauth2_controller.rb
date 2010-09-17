# = Usage
# 
# == Pre-required models (define by yourself)
# 
# * Oauth2::Client
# * Oauth2::AccessToken
# * Oauth2::RefreshToken
# * Oauth2::AuthorizationCode

class Oauth2Controller < ApplicationController
  before_filter :require_authentication, :only => :authorize

  def authorize
    if request.post?
      status, header, response = authorization_endpoint_authenticator.call(request.env)
      case status
      when 302
        redirect_to header['Location']
      else
        render :status => status, :json => response.body
      end
    else
      # render approval page to the resource owner
    end
  end

  def token
    status, header, res = token_endpoint_authenticator.call(request.env)
    response.headers.merge!(header)
    render :status => status, :text => res.body
  end

  private

  def authorization_endpoint_authenticator
    # set realm as server.example.com
    Rack::OAuth2::Server::Authorization.new('server.example.com') do |req, res|
      client = Oauth2::Client.find_by_identifier(req.client_id)
      raise Rack::OAuth2::Server::Unauthorized.new(:invalid_client, 'Invalid client identifier.') unless client
      if params[:approve]
        res.authorize!
        case req.response_type
        when :code
          authorization_code = Oauth2::AuthorizationCode.create(:user => current_user, :client => client)
          res.code = authorization_code.code
        when :token
          access_token = Oauth2::AccessToken.create(:user => @user, :client => @client)
          res.access_token = access_token.token
          res.expires_in = access_token.expires_in
        when :code_and_token
          authorization_code = Oauth2::AuthorizationCode.create(:user => current_user, :client => client)
          access_token = Oauth2::AccessToken.create(:user => @user, :client => @client)
          res.code = authorization_code.code
          res.access_token = access_token.token
          res.expires_in = access_token.expires_in
        end
      else
        raise Rack::OAuth2::Server::Unauthorized.new(:access_denied, 'User rejected the requested access.', :redirect_uri => req.redirect_uri, :state => req.state)
      end
    end
  end

  def token_endpoint_authenticator
    # set realm as server.example.com
    Rack::OAuth2::Server::Token.new('server.example.com') do |req, res|
      case req.grant_type
      when :authorization_code
        begin
          @user, @client = Oauth2::AuthorizationCode.authenticate!(req.code)
        rescue Oauth2::AuthorizationCode::InvalidCode
          raise Rack::OAuth2::Server::Unauthorized.new(:invalid_grant, 'Invalid authorization code.')
        end
      when :refresh_token
        begin
          @user, @client = Oauth2::RefreshToken.authenticate!(req.refresh_token)
        rescue Oauth2::AuthorizationCode::InvalidToken
          raise Rack::OAuth2::Server::Unauthorized.new(:invalid_grant, 'Invalid authorization code.')
        end
      when :password
        begin
          @user = User.authenticate!(req.username, req.password)
          @client = Oauth2::Client.find_by_identifier(req.client_id)
          raise Rack::OAuth2::Server::Unauthorized.new(:invalid_client, 'Invalid client identifier.') unless client
        rescue User::InvalidCredentials
          raise Rack::OAuth2::Server::Unauthorized.new(:invalid_grant, 'Invalid resource ownwer credentials.')
        end
      when :assertion
        # I'm not familiar with SAML, so raise error for now.
        raise Rack::OAuth2::Server::BadRequest.new(:unsupported_grant_type, "SAML is out of the Rails.")
      else
        raise Rack::OAuth2::Server::BadRequest.new(:unsupported_grant_type, "'#{req.grant_type}' isn't supported.")
      end
      access_token = Oauth2::AccessToken.create(:user => @user, :client => @client)
      res.access_token = access_token.token
      res.expires_in = access_token.expires_in
    end
  end

end

