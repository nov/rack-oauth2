require 'spec_helper.rb'

describe Rack::OAuth2::Server::Resource do
  it "should support realm" do
    app = Rack::OAuth2::Server::Resource.new(nil, "server.example.com")
    app.realm.should == "server.example.com"
  end
end