require 'spec_helper'

describe Rack::OAuth2::AccessToken::Bearer do
  let :token do
    Rack::OAuth2::AccessToken::Bearer.new(
      :access_token => 'access_token'
    )
  end
  let(:resource_endpoint) { 'https://server.example.com/resources/fake' }

  [:get, :delete].each do |method|
    before do
      fake_response(method, resource_endpoint, 'resources/fake.txt')
    end

    describe method.to_s.upcase do
      it 'should have Bearer Authorization header' do
        RestClient.should_receive(method).with(
          resource_endpoint,
          :HTTP_AUTHORIZATION => 'Bearer access_token'
        )
        token.send method, resource_endpoint
      end
    end
  end

  [:post, :put].each do |method|
    before do
      fake_response(method, resource_endpoint, 'resources/fake.txt')
    end

    describe method.to_s.upcase do
      it 'should have Bearer Authorization header' do
        RestClient.should_receive(method).with(
          resource_endpoint,
          {:key => :value},
          {:HTTP_AUTHORIZATION => 'Bearer access_token'}
        )
        token.send method, resource_endpoint, {:key => :value}
      end
    end
  end
end