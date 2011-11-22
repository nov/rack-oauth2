require 'spec_helper.rb'

describe Rack::OAuth2::Util do
  let :util do
    Rack::OAuth2::Util
  end

  let :uri do
    'http://client.example.com/callback'
  end

  describe '.rfc3986_encode' do
    subject { util.rfc3986_encode '=+ .-/' }
    it { should == '%3D%2B%20.-%2F' }
  end

  describe '.base64_encode' do
    subject { util.base64_encode '=+ .-/' }
    it { should == 'PSsgLi0v' }
  end

  describe '.compact_hash' do
    subject { util.compact_hash :k1 => 'v1', :k2 => '', :k3 => nil }
    it { should == {:k1 => 'v1'} }
  end

  describe '.parse_uri' do
    context 'when String is given' do
      it { util.parse_uri(uri).should be_a Addressable::URI }
    end

    context 'when URI is given' do
      it { util.parse_uri(URI.parse(uri)).should be_a Addressable::URI }
    end

    context 'when Addressable::URI is given' do
      it 'should be itself' do
        _uri_ = Addressable::URI.parse uri
        util.parse_uri(_uri_).should be _uri_
      end
    end

    context 'when invalid URI is given' do
      it do
        expect do
          util.parse_uri '::'
        end.should raise_error Addressable::URI::InvalidURIError
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

  describe '.uri_match?' do
    context 'when invalid URI is given' do
      it do
        util.uri_match?('::', '::').should be_false
        util.uri_match?(123, 'http://client.example.com/other').should be_false
        util.uri_match?('http://client.example.com/other', nil).should be_false
      end
    end

    context 'when exactly same' do
      it { util.uri_match?(uri, uri).should be_true }
    end

    context 'when wildcard for subdomain' do
      it { util.uri_match?("http://.example.com/callback", uri).should be_true }
      it { util.uri_match?("http://.xample.com/callback", uri).should be_false }
      it { util.uri_match?("http://example.com/callback", uri).should be_false }
    end

    context 'when path prefix matches' do
      it { util.uri_match?(uri, "#{uri}/deep_path").should be_true }
    end

    context 'otherwise' do
      it do
        util.uri_match?(uri, 'http://client.example.com/other').should be_false
        util.uri_match?(uri, 'http://attacker.example.com/callback').should be_false
      end
    end
  end
end
