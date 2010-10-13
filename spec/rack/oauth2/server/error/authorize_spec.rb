require 'spec_helper.rb'

describe Rack::OAuth2::Server::Authorize::Request do
  
  before do
    @request = Rack::OAuth2::Server::Authorize::Request.new(
      Rack::MockRequest.env_for("/authorize", :params => {
        :client_id => "client_id",
        :response_type => "code"
      })
    )
  end

  describe "#error!" do
    it "should raise BadRequest error" do
      lambda do
        @request.error! :something
      end.should raise_error(Rack::OAuth2::Server::BadRequest) { |e|
        e.error.should == :something
        e.description.should be_nil
      }
    end
  end

  describe "#invalid_request!" do
    it "should raise BadRequest error" do
      lambda do
        @request.invalid_request!
      end.should raise_error(Rack::OAuth2::Server::BadRequest) { |e|
        e.error.should == :invalid_request
        e.description.should == Rack::OAuth2::Server::Error::Authorize::DEFAULT_DESCRIPTION[:invalid_request]
      }
    end
  end

  describe "#invalid_client!" do
    it "should raise BadRequest error" do
      lambda do
        @request.invalid_client!
      end.should raise_error(Rack::OAuth2::Server::BadRequest) { |e|
        e.error.should == :invalid_client
        e.description.should == Rack::OAuth2::Server::Error::Authorize::DEFAULT_DESCRIPTION[:invalid_client]
      }
    end
  end

  describe "#unauthorized_client!" do
    it "should raise BadRequest error" do
      lambda do
        @request.unauthorized_client!
      end.should raise_error(Rack::OAuth2::Server::BadRequest) { |e|
        e.error.should == :unauthorized_client
        e.description.should == Rack::OAuth2::Server::Error::Authorize::DEFAULT_DESCRIPTION[:unauthorized_client]
      }
    end
  end

  describe "#redirect_uri_mismatch!" do
    it "should raise BadRequest error" do
      lambda do
        @request.redirect_uri_mismatch!
      end.should raise_error(Rack::OAuth2::Server::BadRequest) { |e|
        e.error.should == :redirect_uri_mismatch
        e.description.should == Rack::OAuth2::Server::Error::Authorize::DEFAULT_DESCRIPTION[:redirect_uri_mismatch]
      }
    end
  end

  describe "#access_denied!" do
    it "should raise BadRequest error" do
      lambda do
        @request.access_denied!
      end.should raise_error(Rack::OAuth2::Server::BadRequest) { |e|
        e.error.should == :access_denied
        e.description.should == Rack::OAuth2::Server::Error::Authorize::DEFAULT_DESCRIPTION[:access_denied]
      }
    end
  end

  describe "#unsupported_response_type!" do
    it "should raise BadRequest error" do
      lambda do
        @request.unsupported_response_type!
      end.should raise_error(Rack::OAuth2::Server::BadRequest) { |e|
        e.error.should == :unsupported_response_type
        e.description.should == Rack::OAuth2::Server::Error::Authorize::DEFAULT_DESCRIPTION[:unsupported_response_type]
      }
    end
  end

  describe "#invalid_scope!" do
    it "should raise BadRequest error" do
      lambda do
        @request.invalid_scope!
      end.should raise_error(Rack::OAuth2::Server::BadRequest) { |e|
        e.error.should == :invalid_scope
        e.description.should == Rack::OAuth2::Server::Error::Authorize::DEFAULT_DESCRIPTION[:invalid_scope]
      }
    end
  end

end