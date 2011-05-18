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
    end

    describe method.to_s.upcase do
      it 'should have OAuth2 Authorization header' do
        RestClient.should_receive(method).with(
          resource_endpoint,
          :AUTHORIZATION => 'OAuth2 access_token'
        )
        token.send method, resource_endpoint
      end
    end
  end

  [:post, :put].each do |method|
    before do
      mock_response(method, resource_endpoint, 'resources/fake.txt')
    end

    describe method.to_s.upcase do
      it 'should have OAuth2 Authorization header' do
        RestClient.should_receive(method).with(
          resource_endpoint,
          {:key => :value},
          {:AUTHORIZATION => 'OAuth2 access_token'}
        )
        token.send method, resource_endpoint, {:key => :value}
      end
    end
  end

  describe '#to_s' do
    subject { token }
    its(:to_s) { should == token.access_token }
  end
end