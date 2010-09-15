class Oauth2Controller < ApplicationController

  def authorize
    authorization_endpoint = Rack::OAuth2::Server::Authorization.new(self) do |req, res|
      # TODO
    end
    status, header, body = authorization_endpoint.call(request.env)
    case status
    when 302
      redirect_to header['Location']
    else
      render :status => status, :json => body
    end
  end

  def token
    token_endpoint = Rack::OAuth2::Server::Token.new(self) do |req, res|
      # TODO
    end
    status, header, body = token_endpoint.call(request.env)
    render :status => status, :json => body
  end

end
