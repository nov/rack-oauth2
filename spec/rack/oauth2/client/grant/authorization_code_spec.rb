require 'spec_helper.rb'

describe Rack::OAuth2::Client::Grant::AuthorizationCode do
  let(:redirect_uri) { 'https://client.example.com/callback' }
  let(:grant) { Rack::OAuth2::Client::Grant::AuthorizationCode }

  context 'when code is given' do
    let :attributes do
      {:code => 'code'}
    end

    context 'when redirect_uri is given' do
      let :attributes do
        {:code => 'code', :redirect_uri => redirect_uri}
      end
      subject { grant.new attributes }
      its(:redirect_uri) { should == redirect_uri }
      its(:to_hash) do
        should == {:grant_type => :authorization_code, :code => 'code', :redirect_uri => redirect_uri}
      end
    end

    context 'otherwise' do
      subject { grant.new attributes }
      its(:redirect_uri) { should be_nil }
      its(:to_hash) do
        should == {:grant_type => :authorization_code, :code => 'code', :redirect_uri => nil}
      end
    end
  end

  context 'otherwise' do
    it do
      expect { grant.new }.should raise_error AttrRequired::AttrMissing
    end
  end
end