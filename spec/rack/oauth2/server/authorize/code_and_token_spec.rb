require 'spec_helper.rb'

describe Rack::OAuth2::Server::Authorize::CodeAndToken do

  context "when authorized" do

    before do
      @app = Rack::OAuth2::Server::Authorize.new do |request, response|
        response.approve!
        response.code = "authorization_code"
        response.access_token = "access_token"
        response.token_type = "bearer"
      end
      @request = Rack::MockRequest.new @app
    end

    it "should redirect to redirect_uri with authorization code and access token in fragment" do
      response = @request.get("/?response_type=code_and_token&client_id=client&redirect_uri=http://client.example.com/callback")
      response.status.should == 302
      response.location.should == "http://client.example.com/callback#access_token=access_token&code=authorization_code"
    end

    context "when redirect_uri already includes query and fragment" do
      it "should keep original query and fragment" do
        response = @request.get("/?response_type=code_and_token&client_id=client&redirect_uri=http://client.example.com/callback?k=v%23fragment")
        response.status.should == 302
        response.location.should == "http://client.example.com/callback?k=v#fragment&access_token=access_token&code=authorization_code"
      end
    end

  end

  context "when denied" do

    before do
      @app = Rack::OAuth2::Server::Authorize.new do |request, response|
        request.access_denied! 'User rejected the requested access.'
      end
      @request = Rack::MockRequest.new @app
    end

    it "should redirect to redirect_uri with error message" do
      response = @request.get("/?response_type=code_and_token&client_id=client&redirect_uri=http://client.example.com/callback")
      response.status.should == 302
      error_message = {
        :error => :access_denied,
        :error_description => "User rejected the requested access."
      }
      response.location.should == "http://client.example.com/callback?#{error_message.to_query}"
    end

  end

end