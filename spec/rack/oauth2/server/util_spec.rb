require 'spec_helper.rb'

describe Rack::OAuth2::Server::Util do
  let :util do
    Rack::OAuth2::Server::Util
  end

  let :uri do
    'http://client.example.com/callback'
  end

  describe '.compact_hash' do
    subject { util.compact_hash :k1 => 'v1', :k2 => '', :k3 => nil }
    it { should == {:k1 => 'v1'} }
  end

  describe '.parse_uri' do
    context 'when String is given' do
      it { util.parse_uri(uri).should be_a URI::Generic }
    end

    context 'when URI is given' do
      it 'should be itself' do
        _uri_ = URI.parse uri
        util.parse_uri(_uri_).should be _uri_
      end
    end

    context 'when invalid URI is given' do
      it do
        expect do
          util.parse_uri '::'
        end.should raise_error URI::InvalidURIError
      end
    end

    context 'otherwise' do
      it do
        expect { util.parse_uri nil }.should raise_error StandardError
        expect { util.parse_uri 123 }.should raise_error StandardError
      end
    end
  end

  describe '.redirect_uri' do
    let(:base_uri) { 'http://client.example.com' }
    let(:params) do
      {:k1 => :v1, :k2 => ''}
    end
    subject { util.redirect_uri base_uri, location, params }

    context 'when location = :fragment' do
      let(:location) { :fragment }
      it { should == "#{base_uri}##{util.compact_hash(params).to_query}" }
    end

    context 'when location = :query' do
      let(:location) { :query }
      it { should == "#{base_uri}?#{util.compact_hash(params).to_query}" }
    end
  end

  describe '.verify_redirect_uri' do
    context 'when invalid URI is given' do
      it do
        util.verify_redirect_uri('::', '::').should be_false
        util.verify_redirect_uri(123, 'http://client.example.com/other').should be_false
        util.verify_redirect_uri('http://client.example.com/other', nil).should be_false
      end
    end

    context 'when exactry same' do
      it { util.verify_redirect_uri(uri, uri).should be_true }
    end

    context 'when path prefix matches' do
      it { util.verify_redirect_uri(uri, "#{uri}/deep_path").should be_true }
    end

    context 'otherwise' do
      it do
        util.verify_redirect_uri(uri, 'http://client.example.com/other').should be_false
        util.verify_redirect_uri(uri, 'http://attacker.example.com/callback').should be_false
      end
    end
  end
end