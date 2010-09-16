require 'spec_helper.rb'

describe Rack::OAuth2::Server::Resource do
  it "should support realm" do
    app = Rack::OAuth2::Server::Resource.new(simple_app, "server.example.com")
    app.realm.should == "server.example.com"
  end
end

describe Rack::OAuth2::Server::Resource, '#call' do

  before do
    @app = Rack::OAuth2::Server::Resource.new(simple_app, "server.example.com") do |request|
      case request.access_token
      when "valid_token"
        # nothing to do
      when "insufficient_scope_token"
        raise Rack::OAuth2::Server::Unauthorized.new(:insufficient_scope, "More scope is required.", :www_authenticate => true)
      when "expired_token"
        raise Rack::OAuth2::Server::Unauthorized.new(:expired_token, "Given access token has been expired.", :www_authenticate => true)
      else
        raise Rack::OAuth2::Server::Unauthorized.new(:invalid_token, "Given access token is invalid.", :www_authenticate => true)
      end
    end
    @request = Rack::MockRequest.new @app
  end

  context "when no access token is given" do
    it "should skip OAuth 2.0 authentication" do
      env = Rack::MockRequest.env_for("/protected_resource")
      status, header, body = @app.call(env)
      status.should == 200
      env[Rack::OAuth2::ACCESS_TOKEN].should be_nil
    end
  end

  context "when valid_token is given" do
    it "should succeed" do
      response = @request.get("/protected_resource?oauth_token=valid_token")
      response.status.should == 200
    end

    it "should store access token in env" do
      env = Rack::MockRequest.env_for("/protected_resource?oauth_token=valid_token")
      @app.call(env)
      env[Rack::OAuth2::ACCESS_TOKEN].should == "valid_token"
    end
  end

  context "when expired_token is given" do
    it "should fail with expired_token error" do
      response = @request.get("/protected_resource?oauth_token=expired_token")
      response.status.should == 401
      response.headers["WWW-Authenticate"].should == "OAuth realm=\"server.example.com\" error_description=\"Given%20access%20token%20has%20been%20expired.\" error=\"expired_token\""
    end

    it "should not store access token in env" do
      env = Rack::MockRequest.env_for("/protected_resource?oauth_token=expired_token")
      @app.call(env)
      env[Rack::OAuth2::ACCESS_TOKEN].should be_nil
    end
  end

  context "when expired_token is given" do
    it "should fail with invalid_token error" do
      response = @request.get("/protected_resource?oauth_token=invalid_token")
      response.status.should == 401
      response.headers["WWW-Authenticate"].should == "OAuth realm=\"server.example.com\" error_description=\"Given%20access%20token%20is%20invalid.\" error=\"invalid_token\""
    end

    it "should not store access token in env" do
      env = Rack::MockRequest.env_for("/protected_resource?oauth_token=invalid_token")
      @app.call(env)
      env[Rack::OAuth2::ACCESS_TOKEN].should be_nil
    end
  end

  context "when multiple access_token is given" do
    it "should fail with invalid_request error" do
      response = @request.get("/protected_resource?oauth_token=invalid_token", "HTTP_AUTHORIZATION" => "OAuth valid_token")
      response.status.should == 400
      response.headers["WWW-Authenticate"].should == "OAuth realm=\"server.example.com\" error_description=\"Both%20Authorization%20header%20and%20payload%20includes%20oauth_token.\" error=\"invalid_request\""
    end
  end

  context "when OAuth 1.0 Authorization header is given" do
    it "should ignore the OAuth params" do
      env = Rack::MockRequest.env_for("/protected_resource", "HTTP_AUTHORIZATION" => "OAuth realm=\"server.example.com\" oauth_consumer_key=\"key\" oauth_token=\"token\" oauth_signature_method=\"HMAC-SHA1\" oauth_signature=\"sig\" oauth_timestamp=\"123456789\" oauth_nonce=\"nonce\"")
      status, header, body = @app.call(env)
      status.should == 200
      env[Rack::OAuth2::ACCESS_TOKEN].should be_nil
    end
  end

  context "when OAuth 1.0 params is given" do
    it "should ignore the OAuth params" do
      env = Rack::MockRequest.env_for("/protected_resource", :params => {
        :oauth_consumer_key => "key",
        :oauth_token => "token",
        :oauth_signature_method => "HMAC-SHA1",
        :oauth_signature => "sig",
        :oauth_timestamp => 123456789,
        :oauth_nonce => "nonce"
      })
      status, header, body = @app.call(env)
      status.should == 200
      env[Rack::OAuth2::ACCESS_TOKEN].should be_nil
    end
  end

end