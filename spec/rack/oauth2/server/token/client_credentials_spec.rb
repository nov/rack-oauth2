require 'spec_helper.rb'

describe Rack::OAuth2::Server::Token::ClientCredentials do
  let(:request) { Rack::MockRequest.new app }
  let(:app) do
    Rack::OAuth2::Server::Token.new do |request, response|
      response.access_token = 'access_token'
      response.token_type = :bearer
    end
  end
  let(:params) do
    {
      :grant_type => 'client_credentials',
      :client_id => 'client_id',
      :client_secret => 'client_secret'
    }
  end
  subject { request.post('/', :params => params) }

  its(:status)       { should == 200 }
  its(:content_type) { should == 'application/json' }
  its(:body)         { should include '"access_token":"access_token"' }
  its(:body)         { should include '"token_type":"bearer"' }
end