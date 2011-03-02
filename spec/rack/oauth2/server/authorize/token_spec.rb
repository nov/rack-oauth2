require 'spec_helper.rb'

describe Rack::OAuth2::Server::Authorize::Token do
  let :request do
    Rack::MockRequest.new app
  end

  let :redirect_uri do
    'http://client.example.com/callback'
  end

  let :access_token do
    'access_token'
  end

  let :token_type do
    'bearer'
  end

  context "when approved" do
    let :app do
      Rack::OAuth2::Server::Authorize.new do |request, response|
        response.redirect_uri = redirect_uri
        response.access_token = access_token
        response.token_type = token_type
        response.approve!
      end
    end

    it 'should redirect with authorization code in fragment' do
      response = request.get("/?response_type=token&client_id=client&redirect_uri=#{redirect_uri}")
      response.status.should == 302
      response.location.should == "#{redirect_uri}#access_token=#{access_token}"
    end

    context 'when redirect_uri is missing' do
      let :app do
        Rack::OAuth2::Server::Authorize.new do |request, response|
          response.access_token = access_token
          response.token_type = token_type
          response.approve!
        end
      end

      it 'should raise AttrRequired::AttrMissing' do
        lambda do
          request.get "/?response_type=token&client_id=client&redirect_uri=#{redirect_uri}"
        end.should raise_error AttrRequired::AttrMissing
      end
    end

    context 'when access_token is missing' do
      let :app do
        Rack::OAuth2::Server::Authorize.new do |request, response|
          response.redirect_uri = redirect_uri
          response.token_type = token_type
          response.approve!
        end
      end

      it 'should raise AttrRequired::AttrMissing' do
        lambda do
          request.get "/?response_type=token&client_id=client&redirect_uri=#{redirect_uri}"
        end.should raise_error AttrRequired::AttrMissing
      end
    end

    context 'when token_type is missing' do
      let :app do
        Rack::OAuth2::Server::Authorize.new do |request, response|
          response.redirect_uri = redirect_uri
          response.access_token = access_token
          response.approve!
        end
      end

      it 'should raise AttrRequired::AttrMissing' do
        lambda do
          request.get "/?response_type=token&client_id=client&redirect_uri=#{redirect_uri}"
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

    it 'should redirect with error in fragment' do
      response = request.get("/?response_type=token&client_id=client&redirect_uri=#{redirect_uri}")
      response.status.should == 302
      error_message = {
        :error => :access_denied,
        :error_description => Rack::OAuth2::Server::Authorize::ErrorMethods::DEFAULT_DESCRIPTION[:access_denied]
      }
      response.location.should == "#{redirect_uri}##{error_message.to_query}"
    end

  end

end