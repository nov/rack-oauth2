require 'spec_helper'

describe Rack::OAuth2::AccessToken::MAC::BodyHash do
  # From the example of MAC spec section 3.2
  # ref) http://tools.ietf.org/pdf/draft-ietf-oauth-v2-http-mac-00.pdf
  subject do
    Rack::OAuth2::AccessToken::MAC::BodyHash.new(
      :algorithm => 'hmac-sha-1',
      :raw_body => 'hello=world%21'
    )
  end
  its(:calculate) { should == 'k9kbtCIy0CkI3/FEfpS/oIDjk6k=' }
end