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
      when "expired_token"
        raise Rack::OAuth2::Server::Unauthorized.new(:expired_token, "Given access token has been expired.", :www_authenticate => true)
      else
        raise Rack::OAuth2::Server::Unauthorized.new(:invalid_token, "Given access token is invalid.", :www_authenticate => true)
      end
    end
    @request = Rack::MockRequest.new @app
  end

  context "when valid_token is given" do
    it "should succeed" do
      response = @request.get("/protected_resource?oauth_token=valid_token")
      response.status.should == 200
    end
  end

  context "when expired_token is given" do
    it "should fail with WWW-Authorization header" do
      response = @request.get("/protected_resource?oauth_token=expired_token")
      response.status.should == 401
      response.headers["WWW-Authenticate"].should == "OAuth realm=\"server.example.com\" error_description=\"Given%20access%20token%20has%20been%20expired.\" error=\"expired_token\""
    end
  end

  context "when expired_token is given" do
    it "should fail with WWW-Authorization header" do
      response = @request.get("/protected_resource?oauth_token=invalid_token")
      response.status.should == 401
      response.headers["WWW-Authenticate"].should == "OAuth realm=\"server.example.com\" error_description=\"Given%20access%20token%20is%20invalid.\" error=\"invalid_token\""
    end
  end

end