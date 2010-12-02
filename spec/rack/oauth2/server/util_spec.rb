require 'spec_helper.rb'

describe Rack::OAuth2::Server::Util, ".parse_uri" do

  context "when String is given" do
    it "should parse it as URI" do
      uri = Rack::OAuth2::Server::Util.parse_uri "http://client.example.com"
      uri.should be_a_kind_of(URI::Generic)
    end
  end

  context "when URI is given" do
    it "should return itself" do
      _uri_ = URI.parse "http://client.example.com"
      uri = Rack::OAuth2::Server::Util.parse_uri _uri_
      uri.should == _uri_
    end
  end

  context "when Integer is given" do
    it "should raise error" do
      lambda do
        Rack::OAuth2::Server::Util.parse_uri 123
      end.should raise_error(StandardError)
    end
  end

end