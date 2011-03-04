require 'spec_helper.rb'

describe Rack::OAuth2::Server::Token::AuthorizationCode do
  let(:request) { Rack::MockRequest.new app }
  let(:params) do
    {
      :grant_type => 'authorization_code',
      :client_id => 'client_id',
      :code => 'authorization_code',
      :redirect_uri => 'http://client.example.com/callback'
    }
  end
  subject { request.post('/', :params => params) }

  context 'when valid code is given' do
    let(:app) do
      Rack::OAuth2::Server::Token.new do |request, response|
        response.access_token = 'access_token'
      end
    end
    its(:status)       { should == 200 }
    its(:content_type) { should == 'application/json' }
    its(:body)         { should == '{"access_token":"access_token"}' }
  end

  Rack::OAuth2::Server::Token::ErrorMethods::DEFAULT_DESCRIPTION.each do |error, default_message|
    status = if error == :invalid_client
      401
    else
      400
    end
    context "when #{error}" do
      let(:app) do
        Rack::OAuth2::Server::Token.new do |request, response|
          request.send "#{error}!"
        end
      end
      its(:status)       { should == status }
      its(:content_type) { should == 'application/json' }
      its(:body)         { should include "\"error\":\"#{error}\"" }
      its(:body)         { should include "\"error_description\":\"#{default_message}\"" }
    end
  end
end