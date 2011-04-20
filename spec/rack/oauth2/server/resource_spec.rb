require 'spec_helper.rb'

describe Rack::OAuth2::Server::Resource do
  subject { Rack::OAuth2::Server::Resource.new(simple_app, 'realm') }
  its(:realm) { should == 'realm' }
end

describe Rack::OAuth2::Server::Resource::Request do
  let(:env) { Rack::MockRequest.env_for('/protected_resource') }
  let(:request) { Rack::OAuth2::Server::Resource::Request.new(env) }

  describe '#setup!' do
    it do
      expect { request.setup! }.should raise_error(RuntimeError, 'Define me!')
    end
  end

  describe '#oauth2?' do
    it do
      expect { request.oauth2? }.should raise_error(RuntimeError, 'Define me!')
    end
  end
end