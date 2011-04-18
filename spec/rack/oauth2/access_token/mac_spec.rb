require 'spec_helper'

describe Rack::OAuth2::AccessToken::MAC do
  subject do
    Rack::OAuth2::AccessToken::MAC.new(
      :access_token => 'access_token',
      :secret => 'secret',
      :algorithm => 'algorithm'
    )
  end

  its(:secret)    { should == 'secret' }
  its(:algorithm) { should == 'algorithm' }
  its(:token_response) do
    should == {
      :token_type => :mac,
      :access_token => 'access_token',
      :secret => 'secret',
      :algorithm => 'algorithm',
      :expires_in => nil,
      :refresh_token => nil,
      :scope => ''
    }
  end
end