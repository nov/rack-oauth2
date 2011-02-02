require 'spec_helper.rb'

describe Rack::OAuth2::Server::Resource::Request do
  
  before do
    @request = Rack::OAuth2::Server::Resource::Request.new(
      Rack::MockRequest.env_for("/resource", :params => {
        :oauth_token => "oauth_token"
      })
    )
  end

  describe "#error!" do
    it "should raise BadRequest error" do
      lambda do
        @request.error! :something
      end.should raise_error(Rack::OAuth2::Server::Error) { |e|
        e.status.should == 400
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
        e.description.should == Rack::OAuth2::Server::Error::Resource::DEFAULT_DESCRIPTION[:invalid_request]
      }
    end
  end

  describe "#invalid_token!" do
    it "should raise Unauthorized error" do
      lambda do
        @request.invalid_token!
      end.should raise_error(Rack::OAuth2::Server::Unauthorized) { |e|
        e.error.should == :invalid_token
        e.description.should == Rack::OAuth2::Server::Error::Resource::DEFAULT_DESCRIPTION[:invalid_token]
      }
    end
  end

  describe "#expired_token!" do
    it "should raise Unauthorized error" do
      lambda do
        @request.expired_token!
      end.should raise_error(Rack::OAuth2::Server::Unauthorized) { |e|
        e.error.should == :expired_token
        e.description.should == Rack::OAuth2::Server::Error::Resource::DEFAULT_DESCRIPTION[:expired_token]
      }
    end
  end

  describe "#insufficient_scope!" do
    it "should raise Forbidden error" do
      lambda do
        @request.insufficient_scope!
      end.should raise_error(Rack::OAuth2::Server::Forbidden) { |e|
        e.error.should == :insufficient_scope
        e.description.should == Rack::OAuth2::Server::Error::Resource::DEFAULT_DESCRIPTION[:insufficient_scope]
      }
    end
  end

end