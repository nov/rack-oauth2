require 'spec_helper.rb'

describe Rack::OAuth2::Server::Resource::Bearer::BadRequest do
  let(:error) { Rack::OAuth2::Server::Resource::Bearer::BadRequest.new(:invalid_request) }

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

describe Rack::OAuth2::Server::Resource::Bearer::Unauthorized do
  let(:error) { Rack::OAuth2::Server::Resource::Bearer::Unauthorized.new(:invalid_token) }

  it { should be_a Rack::OAuth2::Server::Abstract::Unauthorized }
  describe '#finish' do
    it 'should respond in JSON' do
      status, header, response = error.finish
      status.should == 401
      header['Content-Type'].should == 'application/json'
      header['WWW-Authenticate'].should == 'Bearer error="invalid_token"'
      response.body.should == ['{"error":"invalid_token"}']
    end
  end

  context 'when error_code is not invalid_token' do
    let(:error) { Rack::OAuth2::Server::Resource::Bearer::Unauthorized.new(:something) }

    it 'should have error_code in body but not in WWW-Authenticate header' do
      status, header, response = error.finish
      header['WWW-Authenticate'].should == 'Bearer'
      response.body.first.should include '"error":"something"'
    end
  end
end

describe Rack::OAuth2::Server::Resource::Bearer::Forbidden do
  let(:error) { Rack::OAuth2::Server::Resource::Bearer::Forbidden.new(:insufficient_scope) }

  it { should be_a Rack::OAuth2::Server::Abstract::Forbidden }
  describe '#finish' do
    it 'should respond in JSON' do
      status, header, response = error.finish
      status.should == 403
      header['Content-Type'].should == 'application/json'
      response.body.should == ['{"error":"insufficient_scope"}']
    end
  end

  context 'when scope option is given' do
    let(:error) { Rack::OAuth2::Server::Resource::Bearer::Forbidden.new(:insufficient_scope, 'Desc', :scope => [:scope1, :scope2]) }

    it 'should have blank WWW-Authenticate header' do
      status, header, response = error.finish
      response.body.first.should include '"scope":"scope1 scope2"'
    end
  end
end

describe Rack::OAuth2::Server::Resource::Bearer::ErrorMethods do
  let(:bad_request)         { Rack::OAuth2::Server::Resource::Bearer::BadRequest }
  let(:unauthorized)        { Rack::OAuth2::Server::Resource::Bearer::Unauthorized }
  let(:forbidden)           { Rack::OAuth2::Server::Resource::Bearer::Forbidden }
  let(:redirect_uri)        { 'http://client.example.com/callback' }
  let(:default_description) { Rack::OAuth2::Server::Resource::Bearer::ErrorMethods::DEFAULT_DESCRIPTION }
  let(:env)                 { Rack::MockRequest.env_for("/authorize?client_id=client_id") }
  let(:request)             { Rack::OAuth2::Server::Resource::Bearer::Request.new env }

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

  Rack::OAuth2::Server::Resource::Bearer::ErrorMethods::DEFAULT_DESCRIPTION.keys.each do |error_code|
    method = "#{error_code}!"
    case error_code
    when :invalid_request
      describe method do
        it "should raise Rack::OAuth2::Server::Resource::Bearer::BadRequest with error = :#{error_code}" do
          expect { request.send method }.should raise_error(bad_request) { |error|
            error.error.should       == error_code
            error.description.should == default_description[error_code]
          }
        end
      end
    when :insufficient_scope
      describe method do
        it "should raise Rack::OAuth2::Server::Resource::Bearer::Forbidden with error = :#{error_code}" do
          expect { request.send method }.should raise_error(forbidden) { |error|
            error.error.should       == error_code
            error.description.should == default_description[error_code]
          }
        end
      end
    else
      describe method do
        it "should raise Rack::OAuth2::Server::Resource::Bearer::Unauthorized with error = :#{error_code}" do
          expect { request.send method }.should raise_error(unauthorized) { |error|
            error.error.should       == error_code
            error.description.should == default_description[error_code]
          }
        end
      end
    end
  end
end