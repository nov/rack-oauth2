module Rack
  module OAuth2
    module Server

      class Error < StandardError
        attr_accessor :status, :error, :description, :uri, :state, :scope, :redirect_uri

        def initialize(status, error, description = "", options = {})
          @status       = status
          @error        = error
          @description  = description
          @uri          = options[:uri]
          @state        = options[:state]
          @scope        = Array(options[:scope])
          @redirect_uri = Util.parse_uri(options[:redirect_uri]) if options[:redirect_uri]
        end

        def protocol_params
          {
            :error             => error,
            :error_description => description,
            :error_uri         => uri,
            :state             => state,
            :scope             => scope.join(' ')
          }
        end

        def finish
          _protocol_params_ = protocol_params.delete_if do |key, value|
            value.blank?
          end
          if @redirect_uri.present?
            finish_with_redirect _protocol_params_
          else
            finish_with_response_body _protocol_params_
          end
        end

        def finish_with_redirect(_protocol_params_)
          response = Rack::Response.new
          redirect_uri.query = [redirect_uri.query, _protocol_params_.to_query].compact.join('&')
          response.redirect redirect_uri.to_s
          response.finish
        end

        def finish_with_response_body(_protocol_params_)
          response = Rack::Response.new
          response.status = status
          response.header['Content-Type'] = 'application/json'
          response.header['WWW-Authenticate'] = "OAuth2 #{_protocol_params_.collect { |key, value| "#{key}='#{value.to_s}'" }.join(' ')}"
          response.write _protocol_params_.to_json
          response.finish
        end
      end

      class BadRequest < Error
        def initialize(error, description = "", options = {})
          super(400, error, description, options)
        end
      end

      class Unauthorized < Error
        def initialize(error, description = "", options = {})
          super(401, error, description, options)
        end
      end

      class Forbidden < Error
        def initialize(error, description = "", options = {})
          super(403, error, description, options)
        end
      end

    end
  end
end

require 'rack/oauth2/server/error/authorize'
require 'rack/oauth2/server/error/token'
require 'rack/oauth2/server/error/resource'