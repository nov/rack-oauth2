require 'spec_helper.rb'
require 'base64'

describe Rack::OAuth2::Server::Token do
  let(:request) { Rack::MockRequest.new app }
  let(:app) do
    Rack::OAuth2::Server::Token.new do |request, response|
      response.access_token = Rack::OAuth2::AccessToken::Bearer.new(:access_token => 'access_token')
    end
  end
  let(:headers) {{}}
  let(:params) do
    {
      :grant_type => 'authorization_code',
      :client_id => 'client_id',
      :code => 'authorization_code',
      :redirect_uri => 'http://client.example.com/callback'
    }
  end
  subject { request.post('/token', headers.merge(:params => params)) }

  context 'response content type' do
    context 'when HTTP_ACCEPT is application/xml' do
      before do
        headers['HTTP_ACCEPT'] = 'application/xml'
      end
      it "returns XML body" do
        expect(subject.header['Content-Type']).to eql "application/xml"
        expect(subject.body).to match("<OAuth>")
        expect(subject.body).to match("<access-token>access_token</access-token>")
        expect(subject.body).to match(%q{<token-type type="symbol">bearer</token-type>})
      end
    end
    context "when HTTP_ACCEPT is application/json" do
      before do
        headers['HTTP_ACCEPT'] = 'application/json'
      end
      it "returns JSON body" do
        expect(subject.header['Content-Type']).to eql "application/json"
        expect(subject.body).to match(%q{"access_token":"access_token"})
        expect(subject.body).to match(%q{"token_type":"bearer"})
      end
    end
  end

  context 'when multiple client credentials are given' do
    context 'when different credentials are given' do
      let(:env) do
        Rack::MockRequest.env_for(
          '/token',
          'HTTP_AUTHORIZATION' => "Basic #{Base64.encode64('client_id2:client_secret')}",
          :params => params
        )
      end
      it 'should fail with unsupported_grant_type' do
        status, header, response = app.call(env)
        status.should == 400
        response.body.first.should include '"error":"invalid_request"'
      end
    end

    context 'when same credentials are given' do
      let(:env) do
        Rack::MockRequest.env_for(
          '/token',
          'HTTP_AUTHORIZATION' => "Basic #{Base64.encode64('client_id:client_secret')}",
          :params => params
        )
      end
      it 'should ignore duplicates' do
        status, header, response = app.call(env)
        status.should == 200
      end
    end
  end

  context 'when unsupported grant_type is given' do
    before do
      params.merge!(:grant_type => 'unknown')
    end
    its(:status)       { should == 400 }
    its(:content_type) { should == 'application/json' }
    its(:body)         { should include '"error":"unsupported_grant_type"' }
  end

  [:client_id, :grant_type].each do |required|
    context "when #{required} is missing"  do
      before do
        params.delete_if do |key, value|
          key == required
        end
      end

      context "when HTTP_ACCEPT is application/json" do
        before do
          headers["HTTP_ACCEPT"] = "application/json"
        end
        its(:status)       { should == 400 }
        its(:content_type) { should == 'application/json' }
        its(:body)         { should include '"error":"invalid_request"' }
      end

      context "when HTTP_ACCEPT is application/xml"do
        before do
          headers["HTTP_ACCEPT"] = "application/xml"
        end
        its(:status)       { should == 400 }
        its(:content_type) { should == 'application/xml' }
        its(:body)         { should include "<OAuth>" }
        its(:body)         { should include '<error type="symbol">invalid_request</error>' }
      end
    end
  end

  Rack::OAuth2::Server::Token::ErrorMethods::DEFAULT_DESCRIPTION.each do |error, default_message|
    status = error == :invalid_client ? 401 : 400
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

  context 'when responding' do
    context 'when access_token is missing' do
      let(:app) do
        Rack::OAuth2::Server::Token.new
      end
      it do
        expect { request.post('/', :params => params) }.to raise_error AttrRequired::AttrMissing
      end
    end
  end

  describe 'extensibility' do
    before do
      require 'rack/oauth2/server/token/extension/jwt'
    end

    subject { app }
    let(:env) do
      Rack::MockRequest.env_for(
        '/token',
        :params => params
      )
    end
    let(:request) { Rack::OAuth2::Server::Token::Request.new env }
    its(:extensions) { should == [Rack::OAuth2::Server::Token::Extension::JWT] }

    describe 'JWT assertion' do
      let(:params) do
        {
          :grant_type => 'urn:ietf:params:oauth:grant-type:jwt-bearer',
          :assertion => 'header.payload.signature'
        }
      end

      it do
        app.send(
          :grant_type_for, request
        ).should == Rack::OAuth2::Server::Token::Extension::JWT
      end
    end
  end
end
