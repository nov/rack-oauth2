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
    subject { util.compact_hash k1: 'v1', k2: '', k3: nil }
    it { should == {k1: 'v1'} }
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

  describe '.is_blank?' do
    context 'when argument is nil' do
      it do
        expect(util.is_blank?(nil)).to be true
      end
    end

    context 'when argument is empty array' do
      it do
        expect(util.is_blank?([])).to be true
      end
    end

    context 'when argument is nonempty array' do
      it do
        expect(util.is_blank?([1, 2])).to be false
      end
    end

    context 'when argument is empty hash' do
      it do
        expect(util.is_blank?({})).to be true
      end
    end

    context 'when argument is nonempty hash' do
      it do
        expect(util.is_blank?(a: 1)).to be false
      end
    end

    context 'when argument is empty string' do
      it do
        expect(util.is_blank?('')).to be true
      end

      it do
        expect(util.is_blank?("\n")).to be true
      end

      it do
        expect(util.is_blank?("  ")).to be true
      end
    end

    context 'when argument is nonempty string' do
      it do
        expect(util.is_blank?('a')).to be false
      end
    end
  end

  describe '.to_query' do
    let(:params) do
      {k1: :v1, k2: :v2}
    end

    it 'should return valid URI query' do
      expect(util.to_query(params)).to eq "k1=v1&k2=v2"
    end
  end

  describe '.redirect_uri' do
    let(:base_uri) { 'http://client.example.com' }
    let(:params) do
      {k1: :v1, k2: ''}
    end
    subject { util.redirect_uri base_uri, location, params }

    context 'when location = :fragment' do
      let(:location) { :fragment }
      it { should == "#{base_uri}##{util.to_query util.compact_hash params}" }
    end

    context 'when location = :query' do
      let(:location) { :query }
      it { should == "#{base_uri}?#{util.to_query util.compact_hash params}" }
    end
  end

  describe '.uri_match?' do
    context 'when invalid URI is given' do
      it do
        util.uri_match?('::', '::').should == false
        util.uri_match?(123, 'http://client.example.com/other').should == false
        util.uri_match?('http://client.example.com/other', nil).should == false
      end
    end

    context 'when exactry same' do
      it { util.uri_match?(uri, uri).should == true }
    end

    context 'when path prefix matches' do
      it { util.uri_match?(uri, "#{uri}/deep_path").should == true }
    end

    context 'otherwise' do
      it do
        util.uri_match?(uri, 'http://client.example.com/other').should == false
        util.uri_match?(uri, 'http://attacker.example.com/callback').should == false
      end
    end
  end
end
