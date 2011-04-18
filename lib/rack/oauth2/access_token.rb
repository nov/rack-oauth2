module Rack
  module OAuth2
    class AccessToken
      include AttrRequired, AttrOptional
      attr_required :access_token, :token_type
      attr_optional :refresh_token, :expires_in, :scope

      def initialize(attributes = {})
        (required_attributes + optional_attributes).each do |key|
          self.send :"#{key}=", attributes[key]
        end
        @token_type = self.class.to_s.split('::').last.underscore.to_sym
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

require 'rack/oauth2/access_token/bearer'
require 'rack/oauth2/access_token/mac'