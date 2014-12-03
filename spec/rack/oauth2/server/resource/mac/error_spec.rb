require 'spec_helper.rb'

describe Rack::OAuth2::Server::Resource::MAC::Unauthorized do
  let(:error) { Rack::OAuth2::Server::Resource::MAC::Unauthorized.new(:invalid_token) }

  it { is_expected.to be_a Rack::OAuth2::Server::Resource::Unauthorized }

  describe '#scheme' do
    subject { error }
    its(:scheme) { should == :MAC }
  end

  describe '#finish' do
    it 'should use MAC scheme' do
      status, header, response = error.finish
      expect(header['WWW-Authenticate']).to match(/^MAC /)
    end
  end
end

describe Rack::OAuth2::Server::Resource::MAC::ErrorMethods do
  let(:unauthorized)        { Rack::OAuth2::Server::Resource::MAC::Unauthorized }
  let(:redirect_uri)        { 'http://client.example.com/callback' }
  let(:default_description) { Rack::OAuth2::Server::Resource::ErrorMethods::DEFAULT_DESCRIPTION }
  let(:env)                 { Rack::MockRequest.env_for("/authorize?client_id=client_id") }
  let(:request)             { Rack::OAuth2::Server::Resource::MAC::Request.new env }

  describe 'unauthorized!' do
    it do
      expect { request.unauthorized! :invalid_client }.to raise_error unauthorized
    end
  end

  Rack::OAuth2::Server::Resource::Bearer::ErrorMethods::DEFAULT_DESCRIPTION.keys.each do |error_code|
    method = "#{error_code}!"
    case error_code
    when :invalid_request
      # ignore
    when :insufficient_scope
      # ignore
    else
      describe method do
        it "should raise Rack::OAuth2::Server::Resource::Bearer::Unauthorized with error = :#{error_code}" do
          expect { request.send method }.to raise_error(unauthorized) { |error|
            expect(error.error).to       eq(error_code)
            expect(error.description).to eq(default_description[error_code])
          }
        end
      end
    end
  end
end