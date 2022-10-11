require 'spec_helper'

describe Rack::OAuth2::AccessToken::Authenticator do
  let(:resource_endpoint) { 'https://server.example.com/resources/fake' }
  let(:request) { Faraday::Request.new(:get, URI.parse(resource_endpoint)) }
  let(:authenticator) { Rack::OAuth2::AccessToken::Authenticator.new(token) }

  shared_examples_for :authenticator do
    it 'should let the token authenticate the request' do
      expect(token).to receive(:authenticate).with(request)
      authenticator.authenticate(request)
    end
  end

  context 'when Bearer token is given' do
    let(:token) do
      Rack::OAuth2::AccessToken::Bearer.new(
        access_token: 'access_token'
      )
    end
    it_behaves_like :authenticator
  end
end
