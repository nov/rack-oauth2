require 'spec_helper'

describe Rack::OAuth2::AccessToken::MAC do
  let :token do
    Rack::OAuth2::AccessToken::MAC.new(
      :access_token => 'access_token',
      :mac_key => 'secret',
      :mac_algorithm => 'hmac-sha-256',
      :issued_at => issued_at
    )
  end
  let(:issued_at) { 1305820455 }
  let(:nonce) { '1000:51e74de734c05613f37520872e68db5f' }
  let(:resource_endpoint) { 'https://server.example.com/resources/fake' }
  subject { token }

  its(:mac_key)    { should == 'secret' }
  its(:mac_algorithm) { should == 'hmac-sha-256' }
  its(:token_response) do
    should == {
      :access_token => 'access_token',
      :refresh_token => nil,
      :token_type => :mac,
      :expires_in => nil,
      :scope => '',
      :mac_key => 'secret',
      :mac_algorithm => 'hmac-sha-256'
    }
  end
  its(:generate_nonce) { should be_a String }

  describe 'verify!' do
    let(:request) { Rack::OAuth2::Server::Resource::MAC::Request.new(env) }

    context 'when no body_hash is given' do
      let(:env) do
        Rack::MockRequest.env_for(
          '/protected_resources',
          'HTTP_AUTHORIZATION' => %{MAC id="access_token", nonce="#{nonce}", mac="#{signature}"}
        )
      end

      context 'when signature is valid' do
        let(:signature) { 'nbQj0NdvSBKdwvw1yX6wpQ4EwrQKBg/r3lqwJGcthDU=' }
        it do
          token.verify!(request.setup!).should == :verified
        end
      end

      context 'otherwise' do
        let(:signature) { 'invalid' }
        it do
          expect { token.verify!(request.setup!) }.should raise_error(
            Rack::OAuth2::Server::Resource::MAC::Unauthorized,
            'invalid_token :: Signature Invalid'
          )
        end
      end
    end

    context 'when body_hash is given' do
      let(:env) do
        Rack::MockRequest.env_for(
          '/protected_resources',
          :method => :POST,
          :params => {
            :key1 => 'value1'
          },
          'HTTP_AUTHORIZATION' => %{MAC id="access_token", nonce="#{nonce}", bodyhash="#{body_hash}", mac="#{signature}"}
        )
      end
      let(:signature) { 'invalid' }

      context 'when body_hash is invalid' do
        let(:body_hash) { 'invalid' }
        it do
          expect { token.verify!(request.setup!) }.should raise_error(
            Rack::OAuth2::Server::Resource::MAC::Unauthorized,
            'invalid_token :: BodyHash Invalid'
          )
        end
      end

      context 'when body_hash is valid' do
        let(:body_hash) { 'TPzUbFn1S16mpfmwXCi1L+8oZHRxlLX9/D1ZwAV781o=' }

        context 'when signature is valid' do
          let(:signature) { 'ebFlQPMO3WzEZ3ncuIFnVK7IsVt+JEorQEEMJTiz/t8=' }
          it do
            Time.fix(Time.at(1302361200)) do
              token.verify!(request.setup!).should == :verified
            end
          end
        end

        context 'otherwise' do
          it do
            expect { token.verify!(request.setup!) }.should raise_error(
              Rack::OAuth2::Server::Resource::MAC::Unauthorized,
              'invalid_token :: Signature Invalid'
            )
          end
        end
      end
    end
  end

  describe '.authenticate' do
    let(:request) { HTTPClient.new.send(:create_request, :post, URI.parse(resource_endpoint), {}, {:hello => "world"}, {}) }
    let(:body_hash) { 'PQEeCVAqhFUqD4rhEtAkzCwRVZfjpXfV9JAHkCwiHcU=' }
    let(:signature) { 'aL2Oh8gWrCAtJ/Xu6XMtJb6ZsYQT+GxQTs/TgJDQ7ZY=' }

    it 'should set Authorization header' do
      token.should_receive(:generate_nonce).and_return(nonce)
      request.header.should_receive(:[]=).with('Authorization', "MAC id=\"access_token\", nonce=\"#{nonce}\", bodyhash=\"#{body_hash}\", mac=\"#{signature}\"")
      token.authenticate(request)
    end
  end
end
