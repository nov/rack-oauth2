require 'spec_helper.rb'

describe Rack::OAuth2::Server::Authorize::BadRequest do
  let :klass do
    Rack::OAuth2::Server::Authorize::BadRequest
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
    context 'when both redirect_uri and protocol_params_location given' do
      context 'when protocol_params_location is query' do
        it 'should redirect with error in query' do
          error.redirect_uri = 'http://client.example.com/callback'
          error.protocol_params_location = :query
          state, header, response = error.finish
          state.should == 302
          header["Location"].should == 'http://client.example.com/callback?error=invalid_request'
        end
      end

      context 'when protocol_params_location is query' do
        it 'should redirect with error in fragment' do
          error.redirect_uri = 'http://client.example.com/callback'
          error.protocol_params_location = :fragment
          state, header, response = error.finish
          state.should == 302
          header["Location"].should == 'http://client.example.com/callback#error=invalid_request'
        end
      end
    end

    context 'otherwise' do
      it 'should raise itself' do
        lambda do
          error.finish
        end.should raise_error(klass)
      end
    end
  end

end