require 'spec_helper.rb'

describe Rack::OAuth2::Client::Grant::ClientCredentials do
  its(:to_hash) do
    should == {:grant_type => :client_credentials}
  end
end