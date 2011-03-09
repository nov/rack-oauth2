module Rack
  module OAuth2
    class Client
      include AttrRequired, AttrOptional
      attr_required :identifier
      attr_optional :secret, :redirect_uri, :scheme, :host, :response_type, :authorize_endpoint, :token_endpoint

      class Exception < StandardError
        attr_accessor :status, :response
        def initialize(status, response)
          @status = status
          @response = response
          super response[:error_description]
        end
      end

      def initialize(attributes = {})
        (required_attributes + optional_attributes).each do |key|
          self.send "#{key}=", attributes[key]
        end
        @grant = Grant::ClientCredentials.new
        @authorize_endpoint ||= '/oauth2/authorize'
        @token_endpoint ||= '/oauth2/token'
        attr_missing!
      end

      def authorize_url(response_type = :code, params = {})
        absolute_url_for authorize_endpoint, params.merge(
          :client_id => self.identifier,
          :redirect_uri => self.redirect_uri,
          :response_type => response_type
        )
      end

      def authorization_code=(code)
        @grant = Grant::AuthorizationCode.new(
          :code => code,
          :redirect_uri => self.redirect_uri
        )
      end

      def resource_owner_credentials=(username, password)
        @grant = Grant::ResourceOwnerCredentials.new(
          :username => username,
          :password => password
        )
      end

      def access_token!
        params = @grant.to_hash
        params.merge!(
          :client_id => self.identifier,
          :client_secret => self.secret
        )
        handle_response do
          RestClient.post absolute_url_for(token_endpoint), Util.compact_hash(params)
        end
      end

      private

      def absolute_url_for(endpoint, params = {})
        _endpoint_ = Util.parse_uri endpoint
        _endpoint_.scheme ||= 'https'
        _endpoint_.host ||= self.host
        _endpoint_.query = Util.compact_hash(params).to_query
        _endpoint_.to_s
      end

      def handle_response
        response = yield
        JSON.parse(response.body).with_indifferent_access
      rescue RestClient::Exception => e
        error = if e.http_body
          JSON.parse(e.http_body).with_indifferent_access
        else
          {}
        end
        raise Exception.new(e.http_code, error)
      end
    end
  end
end

require 'rack/oauth2/client/grant'