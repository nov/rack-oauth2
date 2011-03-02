require 'spec_helper.rb'

describe Rack::OAuth2::Server::Authorize::BadRequest do
  let :klass do
    Rack::OAuth2::Server::Authorize::BadRequest
  end

  let :redirect_uri do
    'http://client.example.com/callback'
  end

  let :error do
    klass.new(:invalid_request)
  end

  it 'should be a subclass of Abstract::BadRequest' do
    klass.is_a? Rack::OAuth2::Server::Abstract::BadRequest
  end

  describe '#protocol_params' do
    it 'should has all protocol params including state' do
      error.protocol_params.should == {
        :error             => :invalid_request,
        :error_description => nil,
        :error_uri         => nil,
        :state             => nil
      }
    end
  end

  describe '#finish' do
    context 'when both redirect_uri and protocol_params_location are given' do
      context 'when protocol_params_location = :query' do
        it 'should redirect with error in query' do
          error.redirect_uri = redirect_uri
          error.protocol_params_location = :query
          state, header, response = error.finish
          state.should == 302
          header["Location"].should == "#{redirect_uri}?error=invalid_request"
        end
      end

      context 'when protocol_params_location = :fragment' do
        it 'should redirect with error in fragment' do
          error.redirect_uri = redirect_uri
          error.protocol_params_location = :fragment
          state, header, response = error.finish
          state.should == 302
          header["Location"].should == "#{redirect_uri}#error=invalid_request"
        end
      end
    end

    context 'otherwise' do
      it 'should raise itself' do
        lambda do
          error.finish
        end.should raise_error klass
      end
    end
  end
end

describe Rack::OAuth2::Server::Authorize::ErrorMethods do
  let :klass do
    Rack::OAuth2::Server::Authorize::BadRequest
  end

  let :redirect_uri do
    'http://client.example.com/callback'
  end

  let :default_description do
    Rack::OAuth2::Server::Authorize::ErrorMethods::DEFAULT_DESCRIPTION
  end

  let :env do
    Rack::MockRequest.env_for("/authorize?client_id=client_id")
  end

  let :request do
    Rack::OAuth2::Server::Authorize::Request.new env
  end

  let :request_for_code do
    Rack::OAuth2::Server::Authorize::Code::Request.new env
  end

  let :request_for_token do
    Rack::OAuth2::Server::Authorize::Token::Request.new env
  end

  describe 'bad_request!' do
    it 'should raise Authorize::BadRequest' do
      lambda do
        request.bad_request!
      end.should raise_error klass
    end

    context 'when response_type = :code' do
      it 'should set protocol_params_location = :query' do
        lambda do
          request_for_code.bad_request!
        end.should raise_error(klass) { |error|
          error.protocol_params_location.should == :query
        }
      end
    end

    context 'when response_type = :token' do
      it 'should set protocol_params_location = :query' do
        lambda do
          request_for_token.bad_request!
        end.should raise_error(klass) { |error|
          error.protocol_params_location.should == :fragment
        }
      end
    end
  end

  describe 'invalid_request!' do
    it 'should raise Authorize::BadRequest with error = :invalid_request' do
      lambda do
        request.invalid_request!
      end.should raise_error(klass) { |error|
        error.error.should       == :invalid_request
        error.description.should == default_description[:invalid_request]
      }
    end
  end

  describe 'access_denied!' do
    it 'should raise Authorize::BadRequest with error = :access_denied' do
      lambda do
        request.access_denied!
      end.should raise_error(klass) { |error|
        error.error.should       == :access_denied
        error.description.should == default_description[:access_denied]
      }
    end
  end

  describe 'unsupported_response_type!' do
    it 'should raise Authorize::BadRequest with error = :unsupported_response_type' do
      lambda do
        request.unsupported_response_type!
      end.should raise_error(klass) { |error|
        error.error.should       == :unsupported_response_type
        error.description.should == default_description[:unsupported_response_type]
      }
    end
  end

  describe 'invalid_scope!' do
    it 'should raise Authorize::BadRequest with error = :invalid_scope' do
      lambda do
        request.invalid_scope!
      end.should raise_error(klass) { |error|
        error.error.should       == :invalid_scope
        error.description.should == default_description[:invalid_scope]
      }
    end
  end
end