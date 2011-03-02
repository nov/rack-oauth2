require 'spec_helper.rb'

describe Rack::OAuth2::Server::Authorize do
  let :request do
    Rack::MockRequest.new app
  end

  let :redirect_uri do
    'http://client.example.com/callback'
  end

  describe Rack::OAuth2::Server::Authorize::Request do
    let :app do
      Rack::OAuth2::Server::Authorize.new
    end

    let :bad_request do
      Rack::OAuth2::Server::Authorize::BadRequest
    end

    context 'when redirect_uri is missing' do
      it 'should raise Authorize::BadRequest' do
        lambda do
          request.get '/'
        end.should raise_error bad_request
      end
    end

    context 'when redirect_uri is given' do
      context 'when client_id is missing' do
        it 'should raise Authorize::BadRequest' do
          lambda do
            request.get "/?redirect_uri=#{redirect_uri}"
          end.should raise_error bad_request
        end
      end

      context 'when client_id is given' do
        context 'when response_type is missing' do
          it 'should raise Authorize::BadRequest' do
            lambda do
              request.get "/?client_id=client&redirect_uri=#{redirect_uri}"
            end.should raise_error
          end
        end
      end
    end

    context 'when unknown response_type is given' do
      it 'should raise Authorize::BadRequest' do
        lambda do
          request.get "/?response_type=unknown&client_id=client&redirect_uri=#{redirect_uri}"
        end.should raise_error
      end
    end

    context 'when all required parameters are valid' do
      context 'when response_type = :code' do
        it "should succeed" do
          response = request.get "/?response_type=code&client_id=client&redirect_uri=#{redirect_uri}"
          response.status.should == 200
        end
      end

      context 'when response_type = :token' do
        it "should succeed" do
          response = request.get "/?response_type=token&client_id=client&redirect_uri=#{redirect_uri}"
          response.status.should == 200
        end
      end
    end
  end

  describe Rack::OAuth2::Server::Authorize::Response do
    context 'when response_type = :code' do
      let :authorization_code do
        'authorization_code'
      end

      context 'when code is missing' do
        let :app do
          Rack::OAuth2::Server::Authorize.new do |request, response|
            response.redirect_uri = redirect_uri
            response.approve!
          end
        end

        it "should raise AttrRequired::AttrMissing" do
          lambda do
            request.get "/?response_type=code&client_id=client"
          end.should raise_error AttrRequired::AttrMissing
        end
      end

      context 'when redirect_uri is missing' do
        let :app do
          Rack::OAuth2::Server::Authorize.new do |request, response|
            response.code = authorization_code
            response.approve!
          end
        end

        it "should raise AttrRequired::AttrMissing" do
          lambda do
            request.get "/?response_type=code&client_id=client"
          end.should raise_error AttrRequired::AttrMissing
        end
      end

      context 'when both redirect_uri and code are given' do
        let :app do
          Rack::OAuth2::Server::Authorize.new do |request, response|
            response.redirect_uri = redirect_uri
            response.code = authorization_code
            response.approve!
          end
        end

        it 'should redirect with authorization code in query' do
          response = request.get "/?response_type=code&client_id=client&redirect_uri=#{redirect_uri}"
          response.status.should == 302
          response.headers['Location'].should == "#{redirect_uri}?code=#{authorization_code}"
        end
      end
    end
  end
end