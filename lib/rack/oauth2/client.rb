module Rack
  module OAuth2
    class Client
      include AttrRequired, AttrOptional
      attr_required :identifier
      attr_optional :secret, :redirect_uri, :scheme, :host, :port, :authorization_endpoint, :token_endpoint

      def initialize(attributes = {})
        (required_attributes + optional_attributes).each do |key|
          self.send :"#{key}=", attributes[key]
        end
        @grant = Grant::ClientCredentials.new
        @authorization_endpoint ||= '/oauth2/authorize'
        @token_endpoint ||= '/oauth2/token'
        attr_missing!
      end

      def authorization_uri(params = {})
        params[:response_type] ||= :code
        params[:response_type] = Array(params[:response_type]).join(' ')
        params[:scope] = Array(params[:scope]).join(' ')
        Util.redirect_uri absolute_uri_for(authorization_endpoint), :query, params.merge(
          :client_id => self.identifier,
          :redirect_uri => self.redirect_uri
        )
      end

      def authorization_code=(code)
        @grant = Grant::AuthorizationCode.new(
          :code => code,
          :redirect_uri => self.redirect_uri
        )
      end

      def resource_owner_credentials=(credentials)
        @grant = Grant::Password.new(
          :username => credentials.first,
          :password => credentials.last
        )
      end

      def refresh_token=(token)
        @grant = Grant::RefreshToken.new(
          :refresh_token => token
        )
      end

      def access_token!
        params = @grant.to_hash
        params.merge!(
          :client_id => self.identifier,
          :client_secret => self.secret
        )
        handle_response do
          http_client.post absolute_uri_for(token_endpoint), Util.compact_hash(params)
        end
      end

      private

      def http_client
        _http_client_ = HTTPClient.new(
          :agent_name => "#{self.class} (#{VERSION})"
        )
        _http_client_.request_filter << Debugger::RequestFilter.new if Rack::OAuth2.debugging?
        _http_client_
      end

      def absolute_uri_for(endpoint)
        _endpoint_ = Util.parse_uri endpoint
        _endpoint_.scheme ||= self.scheme || 'https'
        _endpoint_.host ||= self.host
        _endpoint_.port ||= self.port
        raise 'No Host Info' unless _endpoint_.host
        _endpoint_.to_s
      end

      def handle_response
        response = yield
        case response.status
        when 200..201
          handle_success_response response
        else
          handle_error_response response
        end
      end

      def handle_success_response(response)
        token_hash = JSON.parse(response.body).with_indifferent_access
        case token_hash[:token_type].try(:downcase)
        when 'bearer'
          AccessToken::Bearer.new(token_hash)
        when 'mac'
          AccessToken::MAC.new(token_hash)
        when nil
          AccessToken::Legacy.new(token_hash)
        else
          raise 'Unknown Token Type'
        end
      rescue JSON::ParserError
        # NOTE: Facebook support (They don't use JSON as token response)
        AccessToken::Legacy.new Rack::Utils.parse_nested_query(response.body).with_indifferent_access
      end

      def handle_error_response(response)
        error = JSON.parse(response.body).with_indifferent_access
        raise Error.new(response.status, error)
      rescue JSON::ParserError
        raise Error.new(response.status, :error => 'Unknown', :error_description => response.body)
      end
    end
  end
end

require 'rack/oauth2/client/error'
require 'rack/oauth2/client/grant'