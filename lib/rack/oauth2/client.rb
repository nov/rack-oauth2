module Rack
  module OAuth2
    class Client
      include AttrRequired, AttrOptional
      attr_required :identifier
      attr_optional :secret, :redirect_uri, :response_type, :authorize_endpoint, :token_endpoint

      def initialize(attributes = {})
        (required_attributes + optional_attributes).each do |key|
          self.send "#{key}=", attributes[key]
        end
        attr_missing!
      end

      def authorize_url(response_type = :code, params = {})
        _params_ = params.merge(
          :client_id => self.identifier,
          :redirect_uri => self.redirect_uri,
          :response_type => response_type
        )
        endpoint = Util.parse_uri authorize_endpoint
        endpoint.query = Util.compact_hash(_params_).to_query
        endpoint.to_s
      end

      def authorization_code=(code)
        @approval = Grant::AuthorizationCode.new(
          :code => code,
          :redirect_uri => self.redirect_uri
        )
      end

      def resource_owner_credentials=(username, password)
        @approval = Grant::ResourceOwnerCredentials.new(
          :username => username,
          :password => password
        )
      end

      def access_token!
        @approval ||= Grant::CrientCredentials.new
        params = @approval.to_hash
        params[:grant_type] ||= :client_credentials
        params.merge!(
          :client_id => self.identifier,
          :client_secret => self.secret
        )
        RestClient.post token_endpoint.to_s, Util.compact_hash(params)
      end
    end
  end
end

require 'rack/oauth2/client/approval'