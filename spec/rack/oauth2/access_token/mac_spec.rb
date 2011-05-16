require 'spec_helper'

describe Rack::OAuth2::AccessToken::MAC do
  let :token do
    Rack::OAuth2::AccessToken::MAC.new(
      :access_token => 'access_token',
      :mac_key => 'secret',
      :mac_algorithm => 'hmac-sha-256'
    )
  end
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

  describe 'HTTP methods' do
    before do
      token.should_receive(:generate_nonce).and_return("51e74de734c05613f37520872e68db5f")
    end

    describe :GET do
      let(:resource_endpoint) { 'https://server.example.com/resources/fake?key=value' }
      it 'should have MAC Authorization header' do
        Time.fix(Time.at(1302361200)) do
          RestClient.should_receive(:get).with(
            resource_endpoint,
            :AUTHORIZATION => 'MAC id="access_token", nonce="51e74de734c05613f37520872e68db5f", mac="OzNHHj7V58g9Yhlc9IRGJu6emDNPsszh8rnz9Ot6M00="'
          )
          token.get resource_endpoint
        end
      end
    end

    describe :POST do
      it 'should have MAC Authorization header' do
        Time.fix(Time.at(1302361200)) do
          RestClient.should_receive(:post).with(
            resource_endpoint,
            {:key => :value},
            {:AUTHORIZATION => 'MAC id="access_token", nonce="51e74de734c05613f37520872e68db5f", bodyhash="Vj8DVxGNBe8UXWvd8pZswj6Gyo8vAT+RXlZa/fCfeiM=", mac="Ob5dT8DrOdFgMW0ygJJlSaX5SjFWNtAeAmkTVh8N/yQ="'}
          )
          token.post resource_endpoint, :key => :value
        end
      end
    end

    describe :PUT do
      it 'should have MAC Authorization header' do
        Time.fix(Time.at(1302361200)) do
          RestClient.should_receive(:put).with(
            resource_endpoint,
            {:key => :value},
            {:AUTHORIZATION => 'MAC id="access_token", nonce="51e74de734c05613f37520872e68db5f", bodyhash="Vj8DVxGNBe8UXWvd8pZswj6Gyo8vAT+RXlZa/fCfeiM=", mac="/0QRwcNZYknY4yMbiOibpSeeu6gkLUy+6QwAGDvMQJw="'}
          )
          token.put resource_endpoint, :key => :value
        end
      end
    end

    describe :DELETE do
      it 'should have MAC Authorization header' do
        Time.fix(Time.at(1302361200)) do
          RestClient.should_receive(:delete).with(
            resource_endpoint,
            :AUTHORIZATION => 'MAC id="access_token", nonce="51e74de734c05613f37520872e68db5f", mac="FDoSkEwGL50VDUZ7/lZvoBtv0fE1yBHXKLdt60E5sao="'
          )
          token.delete resource_endpoint
        end
      end
    end
  end

  describe 'verify!' do
    let(:request) { Rack::OAuth2::Server::Resource::MAC::Request.new(env) }

    context 'when no body_hash is given' do
      let(:env) do
        Rack::MockRequest.env_for(
          '/protected_resources',
          'HTTP_AUTHORIZATION' => %{MAC id="access_token", nonce="51e74de734c05613f37520872e68db5f", mac="#{signature}"}
        )
      end

      context 'when signature is valid' do
        let(:signature) { '1oBk/NOEZ/LN1AB9MNrHiVOywBBujjKuVsdjrfECZag=' }
        it do
          Time.fix(Time.at(1302361200)) do
            token.verify!(request.setup!).should == :verified
          end
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
          'HTTP_AUTHORIZATION' => %{MAC id="access_token", nonce="51e74de734c05613f37520872e68db5f", bodyhash="#{body_hash}", mac="#{signature}"}
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
          let(:signature) { 'ktyTVCFQgOMkLzOx+FPe2KGOd0IOodMC1kR524pXBgg=' }
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
end
