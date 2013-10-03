require 'spec_helper.rb'

describe Rack::OAuth2::Client::Grant::ClientCredentials do
  let(:grant) { Rack::OAuth2::Client::Grant::ClientCredentials }

  context 'when scope is given' do
    let(:scope) { "foo bar" }
    subject { grant.new.tap { |g| g.scope = scope } }

    its(:as_json) do
      should == {:grant_type => :client_credentials, :scope => scope}
    end
  end

  context 'otherwise' do
    its(:as_json) do
      should == {:grant_type => :client_credentials, :scope => nil}
    end
  end
end