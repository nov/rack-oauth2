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
      mock_response method, resource_endpoint, 'resources/fake.txt'
    end

    describe method do
      it 'should have Bearer Authorization header' do
        # TODO: Hot to test filters?
        # token.client.request_filter.last.should_receive(:filter_request)
        p token.client.request_filter.collect(&:class)
        token.client.debug_dev = @str = ''
        token.send method, resource_endpoint
        p @str
      end
    end
  end

  [:post, :put].each do |method|
    before do
      mock_response method, resource_endpoint, 'resources/fake.txt'
    end

    describe method do
      it 'should have Bearer Authorization header' do
        # TODO: Hot to test filters?
        # token.client.request_filter.last.should_receive(:filter_request)
        token.send method, resource_endpoint, :key => :value
      end
    end
  end
end