require 'spec_helper.rb'

describe Rack::OAuth2::Server::Token::Assertion do

  context "when valid assertion is given" do

    before do
      @app = Rack::OAuth2::Server::Token.new(simple_app) do |request, response|
        response.access_token = "access_token"
      end
      @request = Rack::MockRequest.new @app
    end

    it "should return access_token as json response body" do
      response = @request.post("/", :params => {
        :grant_type => "assertion",
        :client_id => "valid_client",
        :assertion => "valid_assertion",
        :assertion_type => "something"
      })
      response.status.should == 200
      response.content_type.should == "application/json"
      response.body.should == {
        :access_token => "access_token"
      }.to_json
    end

  end

  context "when invalid assertion is given" do

    before do
      @app = Rack::OAuth2::Server::Token.new(simple_app) do |request, response|
        raise Rack::OAuth2::Server::BadRequest.new(:invalid_grant, 'Invalid assertion.')
      end
      @request = Rack::MockRequest.new @app
    end

    it "should return error message as json response body" do
      response = @request.post("/", :params => {
        :grant_type => "assertion",
        :client_id => "valid_client",
        :assertion => "invalid_assertion",
        :assertion_type => "something"
      })
      response.status.should == 400
      response.content_type.should == "application/json"
      response.body.should == {
        :error => :invalid_grant,
        :error_description => "Invalid assertion."
      }.to_json
    end

  end

end