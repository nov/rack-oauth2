require 'spec_helper'

describe Rack::OAuth2::AccessToken do
  let :token do
    Rack::OAuth2::AccessToken::Bearer.new(
      access_token: 'access_token',
      refresh_token: 'refresh_token',
      expires_in: 3600,
      scope: [:scope1, :scope2]
    )
  end
  subject { token }

  its(:access_token)  { should == 'access_token' }
  its(:refresh_token) { should == 'refresh_token' }
  its(:expires_in)    { should == 3600 }
  its(:scope)         { should == [:scope1, :scope2] }
  its(:token_response) do
    should == {
      token_type: :bearer,
      access_token: 'access_token',
      refresh_token: 'refresh_token',
      expires_in: 3600,
      scope: 'scope1 scope2'
    }
  end

  context 'when access_token is missing' do
    it do
      expect do
        Rack::OAuth2::AccessToken::Bearer.new(
          refresh_token: 'refresh_token',
          expires_in: 3600,
          scope: [:scope1, :scope2]
        )
      end.to raise_error AttrRequired::AttrMissing
    end
  end

  context 'otherwise' do
    it do
      expect do
        Rack::OAuth2::AccessToken::Bearer.new(
          access_token: 'access_token'
        )
      end.not_to raise_error
    end
  end

  let(:resource_endpoint) { 'https://server.example.com/resources/fake' }
  [:get, :delete, :post, :put].each do |method|
    context 'when extension params given' do
      subject do
        Rack::OAuth2::AccessToken::Bearer.new(
          access_token: 'access_token',
          ex_key: :ex_value
        )
      end

      its(:raw_attributes) { should include :ex_key }
    end
  end
end
