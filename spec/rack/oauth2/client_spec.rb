require 'spec_helper.rb'

describe Rack::OAuth2::Client do
  let :client do
    Rack::OAuth2::Client.new(
      :identifier => 'client_id',
      :secret => 'client_secret',
      :host => 'server.example.com',
      :redirect_uri => 'https://client.example.com/callback'
    )
  end
  subject { client }

  its(:identifier) { should == 'client_id' }
  its(:secret)     { should == 'client_secret' }
  its(:authorization_endpoint) { should == '/oauth2/authorize' }
  its(:token_endpoint)         { should == '/oauth2/token' }

  context 'when identifier is missing' do
    it do
      lambda do
        Rack::OAuth2::Client.new
      end.should raise_error AttrRequired::AttrMissing
    end
  end

  describe '#authorization_uri' do
    subject { client.authorization_uri }
    it { should include 'https://server.example.com/oauth2/authorize' }
    it { should include 'client_id=client_id' }
    it { should include 'redirect_uri=https%3A%2F%2Fclient.example.com%2Fcallback' }
    it { should include 'response_type=code' }

    context 'when endpoints are absolute URIs' do
      before do
        client.authorization_endpoint = 'https://server2.example.com/oauth/authorize'
        client.token_endpoint = 'https://server2.example.com/oauth/token'
      end
      it { should include 'https://server2.example.com/oauth/authorize' }
    end

    context 'when scheme is specified' do
      before { client.scheme = 'http' }
      it { should include 'http://server.example.com/oauth2/authorize' }
    end

    context 'when response_type is token' do
      subject { client.authorization_uri(:response_type => :token) }
      it { should include 'response_type=token' }
    end

    context 'when scope is given' do
      subject { client.authorization_uri(:scope => [:scope1, :scope2]) }
      it { should include 'scope=scope1+scope2' }
    end
  end

  describe '#authorization_code=' do
    before  { client.authorization_code = 'code' }
    subject { client.instance_variable_get('@grant') }
    it { should be_instance_of Rack::OAuth2::Client::Grant::AuthorizationCode }
  end

  describe '#resource_owner_credentials=' do
    before  { client.resource_owner_credentials = 'username', 'password' }
    subject { client.instance_variable_get('@grant') }
    it { should be_instance_of Rack::OAuth2::Client::Grant::Password }
  end

  describe '#access_token!' do
    before  do
      client.authorization_code = 'code'
      fake_response(
        :post,
        'https://server.example.com/oauth2/token',
        'token.json'
      )
    end
    it do
      client.access_token!.should == {
        'access_token' => 'access_token',
        'expires_in' => 3600
      }
    end

    context 'when error response is given' do
      before do
        fake_response(
          :post,
          'https://server.example.com/oauth2/token',
          'invalid_request.json',
          :status => 400
        )
      end
      it do
        lambda do
          client.access_token!
        end.should raise_error Rack::OAuth2::Client::Error
      end
    end
  end
end