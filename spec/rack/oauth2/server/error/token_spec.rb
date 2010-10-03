require 'spec_helper.rb'

describe Rack::OAuth2::Server::Token::Request do
  
  before do
    @request = Rack::OAuth2::Server::Token::Request.new(
      Rack::MockRequest.env_for("/token", :params => {
        :client_id => "client_id",
        :grant_type => "authorization_code",
        :code => "code"
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
        e.description.should == Rack::OAuth2::Server::Error::Token::DEFAULT_DESCRIPTION[:invalid_request]
      }
    end
  end

  describe "#invalid_client!" do
    it "should raise BadRequest error" do
      lambda do
        @request.invalid_client!
      end.should raise_error(Rack::OAuth2::Server::BadRequest) { |e|
        e.error.should == :invalid_client
        e.description.should == Rack::OAuth2::Server::Error::Token::DEFAULT_DESCRIPTION[:invalid_client]
      }
    end

    context "when Authorization header is used" do
      it "should raise Unauthorized error" do
        lambda do
          @request.via_authorization_header = true
          @request.invalid_client!
        end.should raise_error(Rack::OAuth2::Server::Unauthorized) { |e|
          e.error.should == :invalid_client
          e.description.should == Rack::OAuth2::Server::Error::Token::DEFAULT_DESCRIPTION[:invalid_client]
        }
      end
    end
  end

  describe "#unauthorized_client!" do
    it "should raise BadRequest error" do
      lambda do
        @request.unauthorized_client!
      end.should raise_error(Rack::OAuth2::Server::BadRequest) { |e|
        e.error.should == :unauthorized_client
        e.description.should == Rack::OAuth2::Server::Error::Token::DEFAULT_DESCRIPTION[:unauthorized_client]
      }
    end
  end

  describe "#invalid_grant!" do
    it "should raise BadRequest error" do
      lambda do
        @request.invalid_grant!
      end.should raise_error(Rack::OAuth2::Server::BadRequest) { |e|
        e.error.should == :invalid_grant
        e.description.should == Rack::OAuth2::Server::Error::Token::DEFAULT_DESCRIPTION[:invalid_grant]
      }
    end
  end

  describe "#unsupported_grant_type!" do
    it "should raise BadRequest error" do
      lambda do
        @request.unsupported_grant_type!
      end.should raise_error(Rack::OAuth2::Server::BadRequest) { |e|
        e.error.should == :unsupported_grant_type
        e.description.should == Rack::OAuth2::Server::Error::Token::DEFAULT_DESCRIPTION[:unsupported_grant_type]
      }
    end
  end

  describe "#unsupported_response_type!" do
    it "should raise BadRequest error" do
      lambda do
        @request.unsupported_response_type!
      end.should raise_error(Rack::OAuth2::Server::BadRequest) { |e|
        e.error.should == :unsupported_response_type
        e.description.should == Rack::OAuth2::Server::Error::Token::DEFAULT_DESCRIPTION[:unsupported_response_type]
      }
    end
  end

  describe "#invalid_scope!" do
    it "should raise BadRequest error" do
      lambda do
        @request.invalid_scope!
      end.should raise_error(Rack::OAuth2::Server::BadRequest) { |e|
        e.error.should == :invalid_scope
        e.description.should == Rack::OAuth2::Server::Error::Token::DEFAULT_DESCRIPTION[:invalid_scope]
      }
    end
  end

end