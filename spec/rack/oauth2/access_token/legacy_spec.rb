require 'spec_helper'

describe Rack::OAuth2::AccessToken::Legacy do
  let :token do
    Rack::OAuth2::AccessToken::Legacy.new(
      :access_token => 'access_token'
    )
  end
  let(:resource_endpoint) { 'https://server.example.com/resources/fake' }

  [:get, :delete].each do |method|
    before do
      mock_response(method, resource_endpoint, 'resources/fake.txt')
      token.client.debug_dev = @logger = ''
    end

    describe method.to_s.upcase do
      it 'should have OAuth2 Authorization header' do
        # TODO: Hot to test filters?
        # token.client.request_filter.last.should_receive(:filter_request)
        token.send method, resource_endpoint
        p @logger
      end
    end
  end

  [:post, :put].each do |method|
    before do
      mock_response(method, resource_endpoint, 'resources/fake.txt')
    end

    describe method.to_s.upcase do
      it 'should have OAuth2 Authorization header' do
        # TODO: Hot to test filters?
        # token.client.request_filter.last.should_receive(:filter_request)
        token.send method, resource_endpoint, {:key => :value}
      end
    end
  end

  describe '#to_s' do
    subject { token }
    its(:to_s) { should == token.access_token }
  end
end