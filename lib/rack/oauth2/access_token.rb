module Rack
  module OAuth2
    class AccessToken
      include AttrRequired, AttrOptional
      attr_required :access_token, :token_type, :httpclient
      attr_optional :refresh_token, :expires_in, :scope
      delegate :get, :post, :put, :delete, :to => :httpclient

      def initialize(attributes = {})
        (required_attributes + optional_attributes).each do |key|
          self.send :"#{key}=", attributes[key]
        end
        @token_type = self.class.name.demodulize.underscore.to_sym
        @httpclient = Rack::OAuth2.http_client("#{self.class} (#{VERSION})") do |config|
          config.request_filter << Authenticator.new(self)
        end
        attr_missing!
      end

      def token_response(options = {})
        {
          :access_token => access_token,
          :refresh_token => refresh_token,
          :token_type => token_type,
          :expires_in => expires_in,
          :scope => Array(scope).join(' ')
        }
      end
    end
  end
end

require 'rack/oauth2/access_token/authenticator'
require 'rack/oauth2/access_token/bearer'
require 'rack/oauth2/access_token/mac'
require 'rack/oauth2/access_token/legacy'