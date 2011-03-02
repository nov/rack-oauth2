require 'spec_helper.rb'

describe Rack::OAuth2::Server::Abstract::Error do
  let :klass do
    Rack::OAuth2::Server::Abstract::Error
  end

  let :status do
    400
  end

  let :error_code do
    :invalid_request
  end

  let :error_description do
    'Missing some required params'
  end

  let :error_uri do
    'http://server.example.com/error'
  end

  context 'when full attributes given' do
    let :error do
      klass.new status, error_code, error_description, :uri => error_uri
    end

    describe '.new' do
      it 'should store all given params' do
        error.status.should      == status
        error.error.should       == error_code
        error.description.should == error_description
        error.uri.should         == error_uri
      end
    end

    describe '#protocol_params' do
      it 'should has all protocol params' do
        error.protocol_params.should == {
          :error             => error_code,
          :error_description => error_description,
          :error_uri         => error_uri
        }
      end
    end
  end

  context 'when optional attributes not given' do
    let :error do
      klass.new status, error_code
    end

    describe '.new' do
      it 'should store given params' do
        error.status.should      == status
        error.error.should       == error_code
        error.description.should be_nil
        error.uri.should         be_nil
      end
    end

    describe '#protocol_params' do
      it 'should has all protocol params' do
        error.protocol_params.should == {
          :error             => error_code,
          :error_description => nil,
          :error_uri         => nil
        }
      end
    end
  end
end

describe Rack::OAuth2::Server::Abstract::BadRequest do
  let :klass do
    Rack::OAuth2::Server::Abstract::BadRequest
  end

  it "should use 400 as status" do
    klass.new(:invalid_request).status.should == 400
  end
end

describe Rack::OAuth2::Server::Abstract::Unauthorized do
  let :klass do
    Rack::OAuth2::Server::Abstract::Unauthorized
  end

  it "should use 401 as status" do
    klass.new(:invalid_request).status.should == 401
  end
end

describe Rack::OAuth2::Server::Abstract::Forbidden do
  let :klass do
    Rack::OAuth2::Server::Abstract::Forbidden
  end

  it "should use 403 as status" do
    klass.new(:invalid_request).status.should == 403
  end
end
