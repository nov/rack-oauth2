require 'spec_helper.rb'

describe Rack::OAuth2::Server::Token::BadRequest do
  let(:error) { Rack::OAuth2::Server::Token::BadRequest.new(:invalid_request) }

  it { is_expected.to be_a Rack::OAuth2::Server::Abstract::BadRequest }

  describe '#finish' do
    it 'should respond in JSON' do
      status, header, response = error.finish
      expect(status).to eq(400)
      expect(header['Content-Type']).to eq('application/json')
      expect(response.body).to eq(['{"error":"invalid_request"}'])
    end
  end
end

describe Rack::OAuth2::Server::Token::Unauthorized do
  let(:error) { Rack::OAuth2::Server::Token::Unauthorized.new(:invalid_request) }

  it { is_expected.to be_a Rack::OAuth2::Server::Abstract::Unauthorized }

  describe '#finish' do
    it 'should respond in JSON' do
      status, header, response = error.finish
      expect(status).to eq(401)
      expect(header['Content-Type']).to eq('application/json')
      expect(header['WWW-Authenticate']).to eq('Basic realm="OAuth2 Token Endpoint"')
      expect(response.body).to eq(['{"error":"invalid_request"}'])
    end
  end
end

describe Rack::OAuth2::Server::Token::ErrorMethods do
  let(:bad_request)         { Rack::OAuth2::Server::Token::BadRequest }
  let(:unauthorized)        { Rack::OAuth2::Server::Token::Unauthorized }
  let(:redirect_uri)        { 'http://client.example.com/callback' }
  let(:default_description) { Rack::OAuth2::Server::Token::ErrorMethods::DEFAULT_DESCRIPTION }
  let(:env)                 { Rack::MockRequest.env_for("/authorize?client_id=client_id") }
  let(:request)             { Rack::OAuth2::Server::Token::Request.new env }

  describe 'bad_request!' do
    it do
      expect { request.bad_request! :invalid_request }.to raise_error bad_request
    end
  end

  describe 'unauthorized!' do
    it do
      expect { request.unauthorized! :invalid_client }.to raise_error unauthorized
    end
  end

  Rack::OAuth2::Server::Token::ErrorMethods::DEFAULT_DESCRIPTION.keys.each do |error_code|
    method = "#{error_code}!"
    case error_code
    when :invalid_client
      describe method do
        it "should raise Rack::OAuth2::Server::Token::Unauthorized with error = :#{error_code}" do
          expect { request.send method }.to raise_error(unauthorized) { |error|
            expect(error.error).to       eq(error_code)
            expect(error.description).to eq(default_description[error_code])
          }
        end
      end
    else
      describe method do
        it "should raise Rack::OAuth2::Server::Token::BadRequest with error = :#{error_code}" do
          expect { request.send method }.to raise_error(bad_request) { |error|
            expect(error.error).to       eq(error_code)
            expect(error.description).to eq(default_description[error_code])
          }
        end
      end
    end
  end
end