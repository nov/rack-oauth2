require 'spec_helper.rb'

describe Rack::OAuth2::Client::Grant::AuthorizationCode do
  let(:grant) { Rack::OAuth2::Client::Grant::AuthorizationCode }

  context 'when code is given' do
    let :attributes do
      {:code => 'code'}
    end

    context 'when redirect_uri is given' do
      let :attributes do
        {:code => 'code', :redirect_uri => 'https://client.example.com/callback'}
      end
      subject { grant.new attributes }
      its(:redirect_uri) { should == 'https://client.example.com/callback' }
      its(:to_hash) do
        should == {:grant_type => :authorization_code, :code => 'code', :redirect_uri => 'https://client.example.com/callback'}
      end
    end

    context 'otherwise' do
      subject { grant.new attributes }
      its(:redirect_uri) { should be_nil }
      its(:to_hash) do
        should == {:grant_type => :authorization_code, :code => 'code'}
      end
    end
  end

  context 'otherwise' do
    it do
      expect { grant.new }.should raise_error AttrRequired::AttrMissing
    end
  end
end