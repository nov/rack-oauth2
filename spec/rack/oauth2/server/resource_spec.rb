require 'spec_helper.rb'

describe Rack::OAuth2::Server::Resource, '#call' do

  before do
    @app = Rack::OAuth2::Server::Resource.new(simple_app) do |request|
      case request.access_token
      when "valid_token"
        # nothing to do
      when "insufficient_scope_token"
        request.insufficient_scope!("More scope is required.")
      when "expired_token"
        request.expired_token!("Given access token has been expired.")
      else
        request.invalid_token!("Given access token is invalid.")
      end
    end
    @request = Rack::MockRequest.new @app
  end

  context "when no access token is given" do
    it "should skip OAuth 2.0 authentication" do
      env = Rack::MockRequest.env_for("/protected_resource")
      status, header, response = @app.call(env)
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

    context "when Authorization header is used" do
      it "should be accepted" do
        env = Rack::MockRequest.env_for("/protected_resource", "HTTP_AUTHORIZATION" => "OAuth2 valid_token")
        status, header, response = @app.call(env)
        status.should == 200
        env[Rack::OAuth2::ACCESS_TOKEN].should == "valid_token"
      end
    end

    context "when request body is used" do
      it "should be accepted" do
        env = Rack::MockRequest.env_for("/protected_resource", :params => {:oauth_token => "valid_token"})
        status, header, response = @app.call(env)
        status.should == 200
        env[Rack::OAuth2::ACCESS_TOKEN].should == "valid_token"
      end
    end
  end

  context "when expired_token is given" do
    it "should fail with expired_token error" do
      response = @request.get("/protected_resource?oauth_token=expired_token")
      response.status.should == 401
      error_message = {
        :error => :expired_token,
        :error_description => "Given access token has been expired."
      }
      response.headers["WWW-Authenticate"].should == "OAuth2 #{error_message.collect {|k,v| "#{k}='#{v}'"}.join(' ')}"
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
      error_message = {
        :error => :invalid_token,
        :error_description => "Given access token is invalid."
      }
      response.headers["WWW-Authenticate"].should == "OAuth2 #{error_message.collect {|k,v| "#{k}='#{v}'"}.join(' ')}"
    end

    it "should not store access token in env" do
      env = Rack::MockRequest.env_for("/protected_resource?oauth_token=invalid_token")
      @app.call(env)
      env[Rack::OAuth2::ACCESS_TOKEN].should be_nil
    end
  end

  context "when multiple access_token is given" do
    it "should fail with invalid_request error" do
      response = @request.get("/protected_resource?oauth_token=invalid_token", "HTTP_AUTHORIZATION" => "OAuth2 valid_token")
      response.status.should == 400
      error_message = {
        :error => :invalid_request,
        :error_description => "Both Authorization header and payload includes oauth_token."
      }
      response.headers["WWW-Authenticate"].should == "OAuth2 #{error_message.collect {|k,v| "#{k}='#{v}'"}.join(' ')}"
    end
  end

  context "when OAuth 1.0 Authorization header is given" do
    it "should ignore the OAuth params" do
      env = Rack::MockRequest.env_for("/protected_resource", "HTTP_AUTHORIZATION" => "OAuth oauth_consumer_key='key' oauth_token='token' oauth_signature_method='HMAC-SHA1' oauth_signature='sig' oauth_timestamp='123456789' oauth_nonce='nonce'")
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