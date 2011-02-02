require 'spec_helper.rb'

describe Rack::OAuth2::Server::Token::Request do

  before do
    @app = Rack::OAuth2::Server::Token.new do |request, response|
      response.access_token = "access_token"
    end
    @request = Rack::MockRequest.new @app
  end

  context "when any required parameters are missing" do
    it "should return invalid_request error" do
      assert_error_response(:json, :invalid_request) do
        @request.post('/')
      end
      assert_error_response(:json, :invalid_request) do
        @request.post('/', :params => {
          :grant_type => "authorization_code"
        })
      end
      assert_error_response(:json, :invalid_request) do
        @request.post('/', :params => {
          :grant_type => "authorization_code",
          :client_id => "client"
        })
      end
      assert_error_response(:json, :invalid_request) do
        @request.post('/', :params => {
          :grant_type => "authorization_code",
          :redirect_uri => "http://client.example.com/callback"
        })
      end
      assert_error_response(:json, :invalid_request) do
        @request.post('/', :params => {
          :client_id => "client",
          :redirect_uri => "http://client.example.com/callback"
        })
      end
      assert_error_response(:json, :invalid_request) do
        @request.post('/', :params => {
          :grant_type => "authorization_code",
          :redirect_uri => "http://client.example.com/callback"
        })
      end
      assert_error_response(:json, :invalid_request) do
        @request.post('/', :params => {
          :grant_type => "authorization_code",
          :client_id => "client",
          :redirect_uri => "http://client.example.com/callback"
        })
      end
      assert_error_response(:json, :invalid_request) do
        @request.post('/', :params => {
          :grant_type => "authorization_code",
          :code => "authorization_code",
          :redirect_uri => "http://client.example.com/callback"
        })
      end
    end
  end

  context "when unsupported grant_type is given" do
    it "should return unsupported_response_type error" do
      assert_error_response(:json, :unsupported_grant_type) do
        @request.post('/', :params => {
          :grant_type => "hello",
          :client_id => "client",
          :code => "authorization_code",
          :redirect_uri => "http://client.example.com/callback"
        })
      end
    end
  end

  context "when all required parameters are valid" do
    it "should succeed" do
      response = @request.post('/', :params => {
        :grant_type => "authorization_code",
        :client_id => "client",
        :code => "authorization_code",
        :redirect_uri => "http://client.example.com/callback"
      })
      response.status.should == 200
    end
  end

end

describe Rack::OAuth2::Server::Token::Response do

  context "when required response params are missing" do

    before do
      @app = Rack::OAuth2::Server::Token.new do |request, response|
        # access_token is missing
      end
      @request = Rack::MockRequest.new @app
    end

    it "should raise an error" do
      lambda do
        @request.post('/', :params => {
          :grant_type => "authorization_code",
          :client_id => "client",
          :code => "authorization_code",
          :redirect_uri => "http://client.example.com/callback"
        })
      end.should raise_error(StandardError)
    end

  end

  context "when required response params are given" do

    before do
      @app = Rack::OAuth2::Server::Token.new do |request, response|
        response.access_token = "access_token"
      end
      @request = Rack::MockRequest.new @app
    end

    it "should succeed" do
      response = @request.post('/', :params => {
        :grant_type => "authorization_code",
        :client_id => "client",
        :code => "authorization_code",
        :redirect_uri => "http://client.example.com/callback"
      })
      response.status.should == 200
    end

  end

end