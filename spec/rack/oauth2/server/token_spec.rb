require 'spec_helper.rb'
require 'base64'

describe Rack::OAuth2::Server::Token do
  let(:request) { Rack::MockRequest.new app }
  let(:app) do
    Rack::OAuth2::Server::Token.new do |request, response|
      response.access_token = Rack::OAuth2::AccessToken::Bearer.new(access_token: 'access_token')
    end
  end
  let(:params) do
    {
      grant_type: 'authorization_code',
      client_id: 'client_id',
      code: 'authorization_code',
      redirect_uri: 'http://client.example.com/callback'
    }
  end
  subject { request.post('/token', params: params) }

  context 'when multiple client credentials are given' do
    context 'when different credentials are given' do
      let(:env) do
        Rack::MockRequest.env_for(
          '/token',
          'HTTP_AUTHORIZATION' => "Basic #{Base64.encode64('client_id2:client_secret')}",
          params: params
        )
      end
      it 'should fail with unsupported_grant_type' do
        status, headers, response = app.call(env)
        status.should == 400
        response.first.should include '"error":"invalid_request"'
      end
    end

    context 'when same credentials are given' do
      let(:env) do
        Rack::MockRequest.env_for(
          '/token',
          'HTTP_AUTHORIZATION' => "Basic #{Base64.encode64('client_id:client_secret')}",
          params: params
        )
      end
      it 'should ignore duplicates' do
        status, headers, response = app.call(env)
        status.should == 200
      end
    end
  end

  context 'when unsupported grant_type is given' do
    before do
      params.merge!(grant_type: 'unknown')
    end
    its(:status)       { should == 400 }
    its(:content_type) { should == 'application/json' }
    its(:body)         { should include '"error":"unsupported_grant_type"' }
  end

  [:client_id, :grant_type].each do |required|
    context "when #{required} is missing" do
      before do
        params.delete_if do |key, value|
          key == required
        end
      end
      its(:status)       { should == 400 }
      its(:content_type) { should == 'application/json' }
      its(:body)         { should include '"error":"invalid_request"' }
    end
  end

  context 'when client_id is given via JWT client assertion' do
    before do
      require 'json/jwt'
      params[:client_assertion] = JSON::JWT.new(
        sub: params[:client_id]
        # NOTE: actual client_assertion should have more claims.
      ).sign('client_secret').to_s
      params[:client_assertion_type] = Rack::OAuth2::URN::ClientAssertionType::JWT_BEARER
      params.delete(:client_id)
    end

    context 'when client_assertion is invalid JWT' do
      before do
        params[:client_assertion] = 'invalid-jwt'
      end
      its(:status)       { should == 400 }
      its(:content_type) { should == 'application/json' }
      its(:body)         { should include '"error":"invalid_request"' }
    end

    context 'when client_assertion_type is missing' do
      before do
        params.delete(:client_assertion_type)
      end
      its(:status)       { should == 400 }
      its(:content_type) { should == 'application/json' }
      its(:body)         { should include '"error":"invalid_request"' }
    end

    context 'when client_assertion_type is unknown' do
      before do
        params[:client_assertion_type] = 'unknown'
      end
      its(:status)       { should == 400 }
      its(:content_type) { should == 'application/json' }
      its(:body)         { should include '"error":"invalid_request"' }
    end

    context 'when client_assertion issuer is different from client_id' do
      before do
        params[:client_id] = 'another_client_id'
      end
      its(:status)       { should == 400 }
      its(:content_type) { should == 'application/json' }
      its(:body)         { should include '"error":"invalid_request"' }
    end

    context 'otherwise' do
      its(:status)       { should == 200 }
      its(:content_type) { should == 'application/json' }
      its(:body)         { should include '"access_token":"access_token"' }
    end
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
      if error == :invalid_client
        its(:headers)    { should include 'WWW-Authenticate' }
      end
    end
  end

  context 'when skip_www_authenticate option is specified on invalid_client' do
    let(:app) do
      Rack::OAuth2::Server::Token.new do |request, response|
        request.invalid_client!(
          Rack::OAuth2::Server::Token::ErrorMethods::DEFAULT_DESCRIPTION[:invalid_client],
          skip_www_authenticate: true
        )
      end
    end
    its(:headers) { should_not include 'WWW-Authenticate' }
  end

  context 'when responding' do
    context 'when access_token is missing' do
      let(:app) do
        Rack::OAuth2::Server::Token.new
      end
      it do
        expect { request.post('/', params: params) }.to raise_error AttrRequired::AttrMissing
      end
    end
  end

  describe 'extensibility' do
    before do
      require 'rack/oauth2/server/token/extension/example'
    end

    subject { app }
    let(:env) do
      Rack::MockRequest.env_for(
        '/token',
        params: params
      )
    end
    let(:request) { Rack::OAuth2::Server::Token::Request.new env }
    its(:extensions) { should == [Rack::OAuth2::Server::Token::Extension::Example] }

    describe 'JWT assertion' do
      let(:params) do
        {
          grant_type: 'urn:ietf:params:oauth:grant-type:example',
          assertion: 'header.payload.signature'
        }
      end

      it do
        app.send(
          :grant_type_for, request
        ).should == Rack::OAuth2::Server::Token::Extension::Example
      end
    end
  end
end
