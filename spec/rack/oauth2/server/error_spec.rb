require 'spec_helper.rb'

describe Rack::OAuth2::Server::Error, '#finish' do

  context "when state is given" do
    it "should return state as error response" do
      error = Rack::OAuth2::Server::Error.new(400, :invalid_request, "Something Invalid!!", :state => "anything")
      status, header, response = error.finish
      response.body.to_s.should match("\"state\":\"anything\"")
    end
  end

  context "when redirect_uri is given" do
    before do
      @params = {
        :error => :invalid_request,
        :error_description => "Something invalid!!",
        :redirect_uri => "http://client.example.com"
      }
      @error = Rack::OAuth2::Server::Error.new(400, @params[:error], @params[:error_description], :redirect_uri => @params[:redirect_uri])
    end

    it "should redirect to redirect_uri with error message in query string" do
      status, header, response = @error.finish
      status.should == 302
      header['Content-Type'].should == "text/html"
      header['Location'].should == "#{@params.delete(:redirect_uri)}?#{@params.to_query}"
    end

    context "when redirect_uri already includes query" do
      before do
        @params = {
          :error => :invalid_request,
          :error_description => "Something invalid!!",
          :redirect_uri => "http://client.example.com?k=v"
        }
        @error = Rack::OAuth2::Server::Error.new(400, @params[:error], @params[:error_description], :redirect_uri => @params[:redirect_uri])
      end

      it "should keep original query" do
        status, header, response = @error.finish
        status.should == 302
        header['Content-Type'].should == "text/html"
        header['Location'].should == "#{@params.delete(:redirect_uri)}&#{@params.to_query}"
      end
    end
  end

  context "when realm is given" do
    before do
      @params = {
        :error => :invalid_request,
        :error_description => "Something invalid!!"
      }
      @error = Rack::OAuth2::Server::Error.new(401, @params[:error], @params[:error_description], :realm => "server.example.com")
    end

    it "should return failure response with error message in WWW-Authenticate header" do
      status, header, response = @error.finish
      status.should === 401
      error_message = {
        :error => "invalid_request",
        :error_description => "Something invalid!!"
      }
      header['WWW-Authenticate'].should == "OAuth realm='server.example.com' #{error_message.collect {|k,v| "#{k}='#{v}'"}.join(' ')}"
    end
  end

  context "when either redirect_uri nor realm isn't given" do
    before do
      @params = {
        :error => :invalid_request,
        :error_description => "Something invalid!!"
      }
      @error = Rack::OAuth2::Server::Error.new(400, @params[:error], @params[:error_description])
    end

    it "should return failure response with error message in json body" do
      status, header, response = @error.finish
      status.should === 400
      response.body.to_s.should == @params.to_json
    end
    
  end

end

describe Rack::OAuth2::Server::BadRequest do
  it "should use 400 as status" do
    error = Rack::OAuth2::Server::BadRequest.new(:invalid_request)
    error.status.should == 400
  end
end

describe Rack::OAuth2::Server::Unauthorized do
  it "should use 401 as status" do
    error = Rack::OAuth2::Server::Unauthorized.new(:invalid_request)
    error.status.should == 401
  end
end

describe Rack::OAuth2::Server::Forbidden do
  it "should use 403 as status" do
    error = Rack::OAuth2::Server::Forbidden.new(:invalid_request)
    error.status.should == 403
  end
end