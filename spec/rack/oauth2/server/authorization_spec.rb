require 'spec_helper.rb'

describe Rack::OAuth2::Server::Authorization do
  it "should support realm" do
    app = Rack::OAuth2::Server::Authorization.new("server.example.com")
    app.realm.should == "server.example.com"
  end
end

describe Rack::OAuth2::Server::Authorization::Request do

  before do
    @app = Rack::OAuth2::Server::Authorization.new(simple_app) do |request, response|
      response.code = "authorization_code"
    end
    @request = Rack::MockRequest.new @app
  end

  context "when any required parameters are missing" do
    it "should return invalid_request error" do
      assert_error_response(:json, :invalid_request) do
        @request.get('/')
      end
      assert_error_response(:json, :invalid_request) do
        @request.get('/?response_type=code')
      end
      assert_error_response(:json, :invalid_request) do
        @request.get('/?client_id=client')
      end
    end
  end

  context "when unsupported response_type is given" do
    it "should return unsupported_response_type error" do
      assert_error_response(:query, :unsupported_response_type) do
        @request.get('/?response_type=hello&client_id=client&redirect_uri=http://client.example.com/callback')
      end
    end
  end

  context "when all required parameters are valid" do
    it "should succeed" do
      response = @request.get('/?response_type=code&client_id=client')
      response.status.should == 200
    end
  end

end

describe Rack::OAuth2::Server::Authorization::Response do

  context "when required response params are missing" do

    before do
      @app = Rack::OAuth2::Server::Authorization.new(simple_app) do |request, response|
        response.approve!
        # code is missing
      end
      @request = Rack::MockRequest.new @app
    end

    it "should raise an error" do
      lambda do
        @request.get("/?response_type=code&client_id=client&redirect_uri=http://client.example.com/callback")
      end.should raise_error(StandardError)
    end

  end

  context "when required response params are given" do

    before do
      @app = Rack::OAuth2::Server::Authorization.new(simple_app) do |request, response|
        response.approve!
        response.code = "authorization_code"
      end
      @request = Rack::MockRequest.new @app
    end

    it "should succeed" do
      response = @request.get("/?response_type=code&client_id=client&redirect_uri=http://client.example.com/callback")
      response.status.should == 302
    end

  end

end