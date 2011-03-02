require 'spec_helper.rb'

describe Rack::OAuth2::Server::Util do
  let :util do
    Rack::OAuth2::Server::Util
  end

  describe ".parse_uri" do
    context "when String is given" do
      it "should parse it as URI" do
        uri = util.parse_uri "http://client.example.com"
        uri.should be_a_kind_of(URI::Generic)
      end
    end

    context "when URI is given" do
      it "should return itself" do
        _uri_ = URI.parse "http://client.example.com"
        uri = util.parse_uri _uri_
        uri.should == _uri_
      end
    end

    context "when Integer is given" do
      it "should raise error" do
        lambda do
          util.parse_uri 123
        end.should raise_error(StandardError)
      end
    end
  end

  describe ".verify_redirect_uri" do
    context "when exactry matches" do
      it "should be true" do
        util.verify_redirect_uri("http://client.example.com/callback", "http://client.example.com/callback").should be_true
      end
    end

    context "when path prefix matches" do
      it "should be true" do
        util.verify_redirect_uri("http://client.example.com", "http://client.example.com/callback").should be_true
      end
    end

    context "when path prefix didn't matches" do
      it "should be false" do
        util.verify_redirect_uri("http://client.example.com/callback", "http://client.example.com/other").should be_false
      end
    end

    context "when invalid URI given" do
      it "should be false" do
        util.verify_redirect_uri(nil, "http://client.example.com/other").should be_false
        util.verify_redirect_uri("http://client.example.com/other", nil).should be_false
      end
    end
  end
end