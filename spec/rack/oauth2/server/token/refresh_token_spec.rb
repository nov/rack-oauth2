require 'spec_helper.rb'

describe Rack::OAuth2::Server::Token::RefreshToken do

  context "when valid refresh_token is given" do

    before do
      # NOTE: for some reason, test fails when called Rack::OAuth2::Server::Authorization::Token directly
      @app = Rack::OAuth2::Server::Token.new(simple_app) do |request, response|
        response.access_token = "access_token"
      end
      @request = Rack::MockRequest.new @app
    end

    it "should return access_token as json response body" do
      response = @request.post("/", :params => {
        :grant_type => "refresh_token",
        :client_id => "valid_client",
        :refresh_token => "valid_refresh_token"
      })
      response.status.should == 200
      response.content_type.should == "application/json"
      response.body.should == {
        :access_token => "access_token"
      }.to_json
    end

  end

  context "when invalid refresh_token is given" do

    before do
      # NOTE: for some reason, test fails when called Rack::OAuth2::Server::Authorization::Code directly
      @app = Rack::OAuth2::Server::Token.new(simple_app) do |request, response|
        raise Rack::OAuth2::Server::Unauthorized.new(:invalid_grant, 'Invalid refresh_token.')
      end
      @request = Rack::MockRequest.new @app
    end

    it "should return error message as json response body" do
      response = @request.post("/", :params => {
        :grant_type => "refresh_token",
        :client_id => "valid_client",
        :refresh_token => "invalid_refresh_token"
      })
      response.status.should == 401
      response.content_type.should == "application/json"
      response.body.should == {
        :error => :invalid_grant,
        :error_description => "Invalid refresh_token."
      }.to_json
    end

  end

end