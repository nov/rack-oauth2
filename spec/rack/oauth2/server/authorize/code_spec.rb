require 'spec_helper.rb'

describe Rack::OAuth2::Server::Authorize::Code do
  let :request do
    Rack::MockRequest.new app
  end

  let :redirect_uri do
    'http://client.example.com/callback'
  end

  let :authorization_code do
    'authorization_code'
  end

  context 'when approved' do
    let :app do
      Rack::OAuth2::Server::Authorize.new do |request, response|
        response.redirect_uri = redirect_uri
        response.code = 'authorization_code'
        response.approve!
      end
    end

    it 'should redirect with authorization code in query' do
      response = request.get "/?response_type=code&client_id=client&redirect_uri=#{redirect_uri}"
      response.status.should == 302
      response.location.should == "#{redirect_uri}?code=#{authorization_code}"
    end

    context 'when redirect_uri already includes query' do
      let :redirect_uri do
        'http://client.example.com/callback?k=v'
      end

      it 'should keep original query' do
        response = request.get "/?response_type=code&client_id=client&redirect_uri=#{redirect_uri}"
        response.status.should == 302
        response.location.should == "#{redirect_uri}&code=#{authorization_code}"
      end
    end

    context 'when redirect_uri is missing' do
      let :app do
        Rack::OAuth2::Server::Authorize.new do |request, response|
          response.code = authorization_code
          response.approve!
        end
      end

      it 'should raise AttrRequired::AttrMissing' do
        expect do
          request.get "/?response_type=code&client_id=client&redirect_uri=#{redirect_uri}"
        end.should raise_error AttrRequired::AttrMissing
      end
    end

    context 'when code is missing' do
      let :app do
        Rack::OAuth2::Server::Authorize.new do |request, response|
          response.redirect_uri = redirect_uri
          response.approve!
        end
      end

      it 'should raise AttrRequired::AttrMissing' do
        expect do
          request.get "/?response_type=code&client_id=client&redirect_uri=#{redirect_uri}"
        end.should raise_error AttrRequired::AttrMissing
      end
    end
  end

  context 'when denied' do
    let :app do
      Rack::OAuth2::Server::Authorize.new do |request, response|
        request.access_denied!
      end
    end
  
    it 'should redirect with error in query' do
      response = request.get "/?response_type=code&client_id=client&redirect_uri=#{redirect_uri}"
      response.status.should == 302
      error_message = {
        :error => :access_denied,
        :error_description => Rack::OAuth2::Server::Authorize::ErrorMethods::DEFAULT_DESCRIPTION[:access_denied]
      }
      response.location.should == "#{redirect_uri}?#{error_message.to_query}"
    end
  end
end