require 'spec_helper.rb'

describe Rack::OAuth2::Server::Resource::BadRequest do
  let(:error) { Rack::OAuth2::Server::Resource::BadRequest.new(:invalid_request) }

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

describe Rack::OAuth2::Server::Resource::Unauthorized do
  let(:error) { Rack::OAuth2::Server::Resource::Unauthorized.new(:invalid_token) }
  let(:realm) { Rack::OAuth2::Server::Resource::DEFAULT_REALM }

  it { is_expected.to be_a Rack::OAuth2::Server::Abstract::Unauthorized }

  describe '#scheme' do
    it do
      expect { error.scheme }.to raise_error(RuntimeError, 'Define me!')
    end
  end

  context 'when scheme is defined' do
    let :error_with_scheme do
      e = error
      e.instance_eval do
        def scheme
          :Scheme
        end
      end
      e
    end

    describe '#finish' do
      it 'should respond in JSON' do
        status, header, response = error_with_scheme.finish
        expect(status).to eq(401)
        expect(header['Content-Type']).to eq('application/json')
        expect(header['WWW-Authenticate']).to eq("Scheme realm=\"#{realm}\", error=\"invalid_token\"")
        expect(response.body).to eq(['{"error":"invalid_token"}'])
      end

      context 'when error_code is not invalid_token' do
        let(:error) { Rack::OAuth2::Server::Resource::Unauthorized.new(:something) }

        it 'should have error_code in body but not in WWW-Authenticate header' do
          status, header, response = error_with_scheme.finish
          expect(header['WWW-Authenticate']).to eq("Scheme realm=\"#{realm}\"")
          expect(response.body.first).to include '"error":"something"'
        end
      end

      context 'when realm is specified' do
        let(:realm) { 'server.example.com' }
        let(:error) { Rack::OAuth2::Server::Resource::Bearer::Unauthorized.new(:something, nil, :realm => realm) }

        it 'should use given realm' do
          status, header, response = error_with_scheme.finish
          expect(header['WWW-Authenticate']).to eq("Scheme realm=\"#{realm}\"")
          expect(response.body.first).to include '"error":"something"'
        end
      end
    end
  end
end

describe Rack::OAuth2::Server::Resource::Forbidden do
  let(:error) { Rack::OAuth2::Server::Resource::Forbidden.new(:insufficient_scope) }

  it { is_expected.to be_a Rack::OAuth2::Server::Abstract::Forbidden }

  describe '#finish' do
    it 'should respond in JSON' do
      status, header, response = error.finish
      expect(status).to eq(403)
      expect(header['Content-Type']).to eq('application/json')
      expect(response.body).to eq(['{"error":"insufficient_scope"}'])
    end
  end

  context 'when scope option is given' do
    let(:error) { Rack::OAuth2::Server::Resource::Bearer::Forbidden.new(:insufficient_scope, 'Desc', :scope => [:scope1, :scope2]) }

    it 'should have blank WWW-Authenticate header' do
      status, header, response = error.finish
      expect(response.body.first).to include '"scope":"scope1 scope2"'
    end
  end
end

describe Rack::OAuth2::Server::Resource::Bearer::ErrorMethods do
  let(:bad_request)         { Rack::OAuth2::Server::Resource::BadRequest }
  let(:forbidden)           { Rack::OAuth2::Server::Resource::Forbidden }
  let(:redirect_uri)        { 'http://client.example.com/callback' }
  let(:default_description) { Rack::OAuth2::Server::Resource::ErrorMethods::DEFAULT_DESCRIPTION }
  let(:env)                 { Rack::MockRequest.env_for("/authorize?client_id=client_id") }
  let(:request)             { Rack::OAuth2::Server::Resource::Request.new env }

  describe 'bad_request!' do
    it do
      expect { request.bad_request! :invalid_request }.to raise_error bad_request
    end
  end

  describe 'unauthorized!' do
    it do
      expect { request.unauthorized! :invalid_client }.to raise_error(RuntimeError, 'Define me!')
    end
  end

  Rack::OAuth2::Server::Resource::ErrorMethods::DEFAULT_DESCRIPTION.keys.each do |error_code|
    method = "#{error_code}!"
    case error_code
    when :invalid_request
      describe method do
        it "should raise Rack::OAuth2::Server::Resource::BadRequest with error = :#{error_code}" do
          expect { request.send method }.to raise_error(bad_request) { |error|
            expect(error.error).to       eq(error_code)
            expect(error.description).to eq(default_description[error_code])
          }
        end
      end
    when :insufficient_scope
      describe method do
        it "should raise Rack::OAuth2::Server::Resource::Forbidden with error = :#{error_code}" do
          expect { request.send method }.to raise_error(forbidden) { |error|
            expect(error.error).to       eq(error_code)
            expect(error.description).to eq(default_description[error_code])
          }
        end
      end
    else
      describe method do
        it do
          expect { request.send method }.to raise_error(RuntimeError, 'Define me!')
        end
      end
    end
  end
end