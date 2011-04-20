require 'spec_helper'

describe Rack::OAuth2::AccessToken::MAC do
  let :token do
    Rack::OAuth2::AccessToken::MAC.new(
      :access_token => 'access_token',
      :secret => 'secret',
      :algorithm => 'hmac-sha-256'
    )
  end
  let(:resource_endpoint) { 'https://server.example.com/resources/fake' }
  subject { token }

  its(:secret)    { should == 'secret' }
  its(:algorithm) { should == 'hmac-sha-256' }
  its(:token_response) do
    should == {
      :token_type => :mac,
      :access_token => 'access_token',
      :secret => 'secret',
      :algorithm => 'hmac-sha-256',
      :expires_in => nil,
      :refresh_token => nil,
      :scope => ''
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
            :AUTHORIZATION => "MAC token=\"access_token\",timestamp=\"1302361200\",nonce=\"51e74de734c05613f37520872e68db5f\",signature=\"yYDSkZMrEbOOqj0anHNLA9ougNA+lxU0zmPiMSPtmJ8=\""
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
            {:AUTHORIZATION => "MAC token=\"access_token\",timestamp=\"1302361200\",nonce=\"51e74de734c05613f37520872e68db5f\",bodyhash=\"Vj8DVxGNBe8UXWvd8pZswj6Gyo8vAT+RXlZa/fCfeiM=\",signature=\"xRvIiA+rmjhPjULVpyCCgiHEsOkLEHZik4ZaB+cyqgk=\""}
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
            {:AUTHORIZATION => "MAC token=\"access_token\",timestamp=\"1302361200\",nonce=\"51e74de734c05613f37520872e68db5f\",bodyhash=\"Vj8DVxGNBe8UXWvd8pZswj6Gyo8vAT+RXlZa/fCfeiM=\",signature=\"2lWgkUCtD9lNBlDi5fe9eVDwEwbxfLGAqjgykaSV1ww=\""}
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
            :AUTHORIZATION => "MAC token=\"access_token\",timestamp=\"1302361200\",nonce=\"51e74de734c05613f37520872e68db5f\",signature=\"PX2GhHuo5yYNEs51e4Zlllw8itQ4Te0v+6ZuRCK7k+s=\""
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
          'HTTP_AUTHORIZATION' => "MAC token=\"access_token\",timestamp=\"1302361200\",nonce=\"51e74de734c05613f37520872e68db5f\",signature=\"#{signature}\""
        )
      end

      context 'when signature is valid' do
        let(:signature) { 'jaOwJ1eEjabkiRJJ4hdOeVvCGfiCHgeb9NDSrkM0ka4=' }
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
            Rack::OAuth2::AccessToken::MAC::Verifier::VerificationFailed,
            'Signature Invalid'
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
          'HTTP_AUTHORIZATION' => "MAC token=\"access_token\",timestamp=\"1302361200\",nonce=\"51e74de734c05613f37520872e68db5f\",bodyhash=\"#{body_hash}\",signature=\"#{signature}\""
        )
      end
      let(:signature) { 'invalid' }

      context 'when body_hash is invalid' do
        let(:body_hash) { 'invalid' }
        it do
          expect { token.verify!(request.setup!) }.should raise_error(
            Rack::OAuth2::AccessToken::MAC::Verifier::VerificationFailed,
            'BodyHash Invalid'
          )
        end
      end

      context 'when body_hash is valid' do
        let(:body_hash) { 'TPzUbFn1S16mpfmwXCi1L+8oZHRxlLX9/D1ZwAV781o=' }

        context 'when signature is valid' do
          let(:signature) { 'ZSicF/YCg5bdDef103/NLGeuhH7ylHwrnYUUMcCz12A=' }
          it do
            Time.fix(Time.at(1302361200)) do
              token.verify!(request.setup!).should == :verified
            end
          end
        end

        context 'otherwise' do
          it do
            expect { token.verify!(request.setup!) }.should raise_error(
              Rack::OAuth2::AccessToken::MAC::Verifier::VerificationFailed,
              'Signature Invalid'
            )
          end
        end
      end
    end
  end
end
