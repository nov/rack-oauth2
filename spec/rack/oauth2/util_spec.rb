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
    it { is_expected.to eq('%3D%2B%20.-%2F') }
  end

  describe '.base64_encode' do
    subject { util.base64_encode '=+ .-/' }
    it { is_expected.to eq('PSsgLi0v') }
  end

  describe '.compact_hash' do
    subject { util.compact_hash :k1 => 'v1', :k2 => '', :k3 => nil }
    it { is_expected.to eq({:k1 => 'v1'}) }
  end

  describe '.parse_uri' do
    context 'when String is given' do
      it { expect(util.parse_uri(uri)).to be_a URI::Generic }
    end

    context 'when URI is given' do
      it 'should be itself' do
        _uri_ = URI.parse uri
        expect(util.parse_uri(_uri_)).to be _uri_
      end
    end

    context 'when invalid URI is given' do
      it do
        expect do
          util.parse_uri '::'
        end.to raise_error URI::InvalidURIError
      end
    end

    context 'otherwise' do
      it do
        expect { util.parse_uri nil }.to raise_error StandardError
        expect { util.parse_uri 123 }.to raise_error StandardError
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
      it { is_expected.to eq("#{base_uri}##{util.compact_hash(params).to_query}") }
    end

    context 'when location = :query' do
      let(:location) { :query }
      it { is_expected.to eq("#{base_uri}?#{util.compact_hash(params).to_query}") }
    end
  end

  describe '.uri_match?' do
    context 'when invalid URI is given' do
      it do
        expect(util.uri_match?('::', '::')).to eq(false)
        expect(util.uri_match?(123, 'http://client.example.com/other')).to eq(false)
        expect(util.uri_match?('http://client.example.com/other', nil)).to eq(false)
      end
    end

    context 'when exactry same' do
      it { expect(util.uri_match?(uri, uri)).to eq(true) }
    end

    context 'when path prefix matches' do
      it { expect(util.uri_match?(uri, "#{uri}/deep_path")).to eq(true) }
    end

    context 'otherwise' do
      it do
        expect(util.uri_match?(uri, 'http://client.example.com/other')).to eq(false)
        expect(util.uri_match?(uri, 'http://attacker.example.com/callback')).to eq(false)
      end
    end
  end
end