require 'spec_helper.rb'

shared_examples_for :respond_in_json do
  let(:respnse) { error.finish.last }
  its(:status)
  it { should_not be_empty }
  it { should have(1).element }
end

describe Rack::OAuth2::Server::Token::BadRequest do
  let(:klass) { Rack::OAuth2::Server::Token::BadRequest }
  let(:error) { klass.new(:invalid_request) }

  it { should be_a Rack::OAuth2::Server::Abstract::BadRequest }

  describe '#finish' do
    it 'should respond in JSON' do
      status, header, response = error.finish
      status.should == 400
      header['Content-Type'].should == 'application/json'
      response.body.should == ['{"error":"invalid_request"}']
    end
  end
end

describe Rack::OAuth2::Server::Token::Unauthorized do
  let(:klass) { Rack::OAuth2::Server::Token::Unauthorized }
  let(:error) { klass.new(:invalid_request) }

  it { should be_a Rack::OAuth2::Server::Abstract::Unauthorized }

  describe '#finish' do
    it 'should respond in JSON' do
      status, header, response = error.finish
      status.should == 401
      header['Content-Type'].should == 'application/json'
      header['WWW-Authenticate'].should == 'Basic realm="OAuth2 Token Endpoint"'
      response.body.should == ['{"error":"invalid_request"}']
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
      expect { request.bad_request! :invalid_request }.should raise_error bad_request
    end
  end

  describe 'unauthorized!' do
    it do
      expect { request.unauthorized! :invalid_client }.should raise_error unauthorized
    end
  end

  Rack::OAuth2::Server::Token::ErrorMethods::DEFAULT_DESCRIPTION.keys.each do |error_code|
    method = "#{error_code}!"
    case error_code
    when :invalid_client
      describe method do
        it "should raise Rack::OAuth2::Server::Token::Unauthorized with error = :#{error_code}" do
          expect { request.send method }.should raise_error(unauthorized) { |error|
            error.error.should       == error_code
            error.description.should == default_description[error_code]
          }
        end
      end
    else
      describe method do
        it "should raise Rack::OAuth2::Server::Token::BadRequest with error = :#{error_code}" do
          expect { request.send method }.should raise_error(bad_request) { |error|
            error.error.should       == error_code
            error.description.should == default_description[error_code]
          }
        end
      end
    end
  end
end