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
      expect { Rack::OAuth2::Client.new }.to raise_error AttrRequired::AttrMissing
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

    context 'when response_type is an Array' do
      subject { client.authorization_uri(:response_type => [:token, :code]) }
      it { should include 'response_type=token+code' }
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

  describe '#refresh_token=' do
    before  { client.refresh_token = 'refresh_token' }
    subject { client.instance_variable_get('@grant') }
    it { should be_instance_of Rack::OAuth2::Client::Grant::RefreshToken }
  end

  describe '#access_token!' do
    subject { client.access_token! }

    describe 'client authentication method' do
      before do
        client.authorization_code = 'code'
      end

      it 'should be Basic auth as default' do
        mock_response(
          :post,
          'https://server.example.com/oauth2/token',
          'tokens/bearer.json',
          :request_header => {
            'Authorization' => 'Basic Y2xpZW50X2lkOmNsaWVudF9zZWNyZXQ='
          }
        )
        client.access_token!
      end

      context 'when other auth method specified' do
        it do
          mock_response(
            :post,
            'https://server.example.com/oauth2/token',
            'tokens/bearer.json',
            :params => {
              :client_id => 'client_id',
              :client_secret => 'client_secret',
              :code => 'code',
              :grant_type => 'authorization_code',
              :redirect_uri => 'https://client.example.com/callback'
            }
          )
          client.access_token! :client_auth_body
        end
      end
    end

    describe 'scopes' do
      context 'when scope option given' do
        it 'should specify given scope' do
          mock_response(
            :post,
            'https://server.example.com/oauth2/token',
            'tokens/bearer.json',
            :params => {
              :grant_type => 'client_credentials',
              :scope => 'a b'
            }
          )
          client.access_token! :scope => [:a, :b]
        end
      end
    end

    context 'when bearer token is given' do
      before  do
        client.authorization_code = 'code'
        mock_response(
          :post,
          'https://server.example.com/oauth2/token',
          'tokens/bearer.json'
        )
      end
      it { should be_instance_of Rack::OAuth2::AccessToken::Bearer }
      its(:token_type) { should == :bearer }
      its(:access_token) { should == 'access_token' }
      its(:refresh_token) { should == 'refresh_token' }
      its(:expires_in) { should == 3600 }

      context 'when token type is "Bearer", not "bearer"' do
        before  do
          client.authorization_code = 'code'
          mock_response(
            :post,
            'https://server.example.com/oauth2/token',
            'tokens/_Bearer.json'
          )
        end
        it { should be_instance_of Rack::OAuth2::AccessToken::Bearer }
        its(:token_type) { should == :bearer }
      end
    end

    context 'when mac token is given' do
      before  do
        client.authorization_code = 'code'
        mock_response(
          :post,
          'https://server.example.com/oauth2/token',
          'tokens/mac.json'
        )
      end
      it { should be_instance_of Rack::OAuth2::AccessToken::MAC }
      its(:token_type) { should == :mac }
      its(:access_token) { should == 'access_token' }
      its(:refresh_token) { should == 'refresh_token' }
      its(:expires_in) { should == 3600 }
    end

    context 'when no-type token is given (JSON)' do
      before  do
        client.authorization_code = 'code'
        mock_response(
          :post,
          'https://server.example.com/oauth2/token',
          'tokens/legacy.json'
        )
      end
      it { should be_instance_of Rack::OAuth2::AccessToken::Legacy }
      its(:token_type) { should == :legacy }
      its(:access_token) { should == 'access_token' }
      its(:refresh_token) { should == 'refresh_token' }
      its(:expires_in) { should == 3600 }
    end

    context 'when no-type token is given (key-value)' do
      before do
        mock_response(
          :post,
          'https://server.example.com/oauth2/token',
          'tokens/legacy.txt'
        )
      end
      it { should be_instance_of Rack::OAuth2::AccessToken::Legacy }
      its(:token_type) { should == :legacy }
      its(:access_token) { should == 'access_token' }
      its(:expires_in) { should == 3600 }

      context 'when expires_in is not given' do
        before do
          mock_response(
            :post,
            'https://server.example.com/oauth2/token',
            'tokens/legacy_without_expires_in.txt'
          )
        end
        its(:expires_in) { should be_nil }
      end
    end

    context 'when unknown-type token is given' do
      before  do
        client.authorization_code = 'code'
        mock_response(
          :post,
          'https://server.example.com/oauth2/token',
          'tokens/unknown.json'
        )
      end
      it do
        expect { client.access_token! }.to raise_error(StandardError, 'Unknown Token Type')
      end
    end

    context 'when error response is given' do
      before do
        mock_response(
          :post,
          'https://server.example.com/oauth2/token',
          'errors/invalid_request.json',
          :status => 400
        )
      end
      it do
        expect { client.access_token! }.to raise_error Rack::OAuth2::Client::Error
      end
    end

    context 'when no body given' do
      context 'when error given' do
        before do
          mock_response(
            :post,
            'https://server.example.com/oauth2/token',
            'blank',
            :status => 400
          )
        end
        it do
          expect { client.access_token! }.to raise_error Rack::OAuth2::Client::Error
        end
      end
    end
  end

  context 'when no host info' do
    let :client do
      Rack::OAuth2::Client.new(
        :identifier => 'client_id',
        :secret => 'client_secret',
        :redirect_uri => 'https://client.example.com/callback'
      )
    end

    describe '#authorization_uri' do
      it do
        expect { client.authorization_uri }.to raise_error 'No Host Info'
      end
    end

    describe '#access_token!' do
      it do
        expect { client.access_token! }.to raise_error 'No Host Info'
      end
    end
  end
end