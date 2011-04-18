require 'spec_helper'

describe Rack::OAuth2::AccessToken do
  subject do
    Rack::OAuth2::AccessToken::Bearer.new(
      :access_token => 'access_token',
      :refresh_token => 'refresh_token',
      :expires_in => 3600,
      :scope => [:scope1, :scope2]
    )
  end

  its(:access_token)  { should == 'access_token' }
  its(:refresh_token) { should == 'refresh_token' }
  its(:expires_in)    { should == 3600 }
  its(:scope)         { should == [:scope1, :scope2] }
  its(:protocol_params) do
    should == {
      :token_type => :bearer,
      :access_token => 'access_token',
      :refresh_token => 'refresh_token',
      :expires_in => 3600,
      :scope => 'scope1 scope2'
    }
  end

  context 'when access_token is missing' do
    it do
      expect do
        Rack::OAuth2::AccessToken::Bearer.new(
          :refresh_token => 'refresh_token',
          :expires_in => 3600,
          :scope => [:scope1, :scope2]
        )
      end.should raise_error AttrRequired::AttrMissing
    end
  end

  context 'otherwise' do
    it do
      expect do
        Rack::OAuth2::AccessToken::Bearer.new(
          :access_token => 'access_token'
        )
      end.should_not raise_error
    end
  end
end