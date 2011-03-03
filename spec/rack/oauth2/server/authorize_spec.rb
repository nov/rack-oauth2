require 'spec_helper.rb'

describe Rack::OAuth2::Server::Authorize do
  let(:app)          { Rack::OAuth2::Server::Authorize.new }
  let(:request)      { Rack::MockRequest.new app }
  let(:redirect_uri) { 'http://client.example.com/callback' }
  let(:bad_request)  { Rack::OAuth2::Server::Authorize::BadRequest }

  context 'when redirect_uri is missing' do
    it do
      expect { request.get '/' }.should raise_error bad_request
    end
  end

  context 'when redirect_uri is given' do
    context 'when client_id is missing' do
      it do
        expect { request.get "/?redirect_uri=#{redirect_uri}" }.should raise_error bad_request
      end
    end
    context 'when client_id is given' do
      context 'when response_type is missing' do
        it do
          expect { request.get "/?client_id=client&redirect_uri=#{redirect_uri}" }.should raise_error bad_request
        end
      end
    end
  end

  context 'when unknown response_type is given' do
    it do
      expect { request.get "/?response_type=unknown&client_id=client&redirect_uri=#{redirect_uri}" }.should raise_error bad_request
    end
  end

  context 'when all required parameters are valid' do
    [:code, :token].each do |request_type|
      context "when response_type = :#{request_type}" do
        subject { request.get "/?response_type=#{request_type}&client_id=client&redirect_uri=#{redirect_uri}" }
        its(:status) { should == 200 }
      end
    end
  end
end