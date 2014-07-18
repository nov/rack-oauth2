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

      def access_token!(*args)
        headers, params = {}, @grant.as_json

        # NOTE:
        #  Using Array#estract_options! for backward compatibility.
        #  Until v1.0.5, the first argument was 'client_auth_method' in scalar.
        options = args.extract_options!
        client_auth_method = args.first || options[:client_auth_method] || :basic

        params[:scope] = Array(options[:scope]).join(' ') if options[:scope].present?

        if secret && client_auth_method == :basic
          cred = ["#{identifier}:#{secret}"].pack('m').tr("\n", '')
          headers.merge!(
            'Authorization' => "Basic #{cred}"
          )
        else
          params.merge!(
            :client_id => identifier,
            :client_secret => secret
          )
        end
        handle_response do
          Rack::OAuth2.http_client.post(
            absolute_uri_for(token_endpoint),
            Util.compact_hash(params),
            headers
          )
        end
      end

      private

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
        token_hash = parse_json response.body
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
      rescue MultiJson::DecodeError
        # NOTE: Facebook support (They don't use JSON as token response)
        AccessToken::Legacy.new Rack::Utils.parse_nested_query(response.body).with_indifferent_access
      end

      def handle_error_response(response)
        error = parse_json response.body
        raise Error.new(response.status, error)
      rescue MultiJson::DecodeError
        raise Error.new(response.status, :error => 'Unknown', :error_description => response.body)
      end

      def parse_json(raw_json)
        # MultiJson.parse('') returns nil when using MultiJson::Adapters::JsonGem
        MultiJson.load(raw_json).try(:with_indifferent_access) || {}
      end
    end
  end
end

require 'rack/oauth2/client/error'
require 'rack/oauth2/client/grant'