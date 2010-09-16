require 'spec_helper.rb'

describe Rack::OAuth2::Server::Token::AuthorizationCode do

  context "when valid code is given" do

    before do
      # NOTE: for some reason, test fails when called Rack::OAuth2::Server::Authorization::Token directly
      @app = Rack::OAuth2::Server::Token.new(simple_app) do |request, response|
        response.access_token = "access_token"
      end
      @request = Rack::MockRequest.new @app
    end

    it "should return access_token as json response body" do
      response = @request.post("/", :params => {
        :grant_type => "authorization_code",
        :client_id => "valid_client",
        :code => "valid_authorization_code",
        :redirect_uri => "http://client.example.com/callback"
      })
      response.status.should == 200
      response.content_type.should == "application/json"
      response.body.should == "{\"access_token\":\"access_token\"}"
    end

  end

  context "when invalid code is given" do

    before do
      # NOTE: for some reason, test fails when called Rack::OAuth2::Server::Authorization::Code directly
      @app = Rack::OAuth2::Server::Token.new(simple_app) do |request, response|
        raise Rack::OAuth2::Server::Unauthorized.new(:invalid_grant, 'Invalid authorization code.')
      end
      @request = Rack::MockRequest.new @app
    end

    it "should return error message as json response body" do
      response = @request.post("/", :params => {
        :grant_type => "authorization_code",
        :client_id => "valid_client",
        :code => "invalid_authorization_code",
        :redirect_uri => "http://client.example.com/callback"
      })
      response.status.should == 401
      response.content_type.should == "application/json"
      response.body.should == "{\"error_description\":\"Invalid authorization code.\",\"error\":\"invalid_grant\"}"
    end

  end

  context "when invalid client_id is given" do

    before do
      # NOTE: for some reason, test fails when called Rack::OAuth2::Server::Authorization::Code directly
      @app = Rack::OAuth2::Server::Token.new(simple_app) do |request, response|
        raise Rack::OAuth2::Server::Unauthorized.new(:invalid_client, 'Invalid client identifier.')
      end
      @request = Rack::MockRequest.new @app
    end

    it "should return error message as json response body" do
      response = @request.post("/", :params => {
        :grant_type => "authorization_code",
        :client_id => "invalid_client",
        :code => "valid_authorization_code",
        :redirect_uri => "http://client.example.com/callback"
      })
      response.status.should == 401
      response.content_type.should == "application/json"
      response.body.should == "{\"error_description\":\"Invalid client identifier.\",\"error\":\"invalid_client\"}"
    end

  end

end