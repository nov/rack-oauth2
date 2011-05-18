require 'spec_helper'

describe Rack::OAuth2::AccessToken::MAC::Signature do

  # From the example of MAC spec section 1.2
  # ref) http://tools.ietf.org/pdf/draft-ietf-oauth-v2-http-mac-00.pdf
  context 'when body_hash is given' do
    subject do
      Rack::OAuth2::AccessToken::MAC::Signature.new(
        :secret      => '8yfrufh348h',
        :algorithm   => 'hmac-sha-1',
        :nonce       => '273156:di3hvdf8',
        :method      => 'POST',
        :request_uri => '/request',
        :host        => 'example.com',
        :port        => 80,
        :body_hash   => 'k9kbtCIy0CkI3/FEfpS/oIDjk6k=',
        :ext         => nil
      )
    end
    its(:calculate) { should == 'W7bdMZbv9UWOTadASIQHagZyirA=' }
  end

  # From the example of MAC spec section 3.2
  # ref) http://tools.ietf.org/pdf/draft-ietf-oauth-v2-http-mac-00.pdf
  context 'otherwize' do
    subject do
      Rack::OAuth2::AccessToken::MAC::Signature.new(
        :secret      => '489dks293j39',
        :algorithm   => 'hmac-sha-1',
        :nonce       => '264095:dj83hs9s',
        :method      => 'GET',
        :request_uri => '/resource/1?b=1&a=2',
        :host        => 'example.com',
        :port        => 80,
        :body_hash   => nil,
        :ext         => nil
      )
    end
    its(:calculate) { should == 'SLDJd4mg43cjQfElUs3Qub4L6xE=' }
  end

end