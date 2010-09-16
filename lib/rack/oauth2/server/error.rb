module Rack
  module OAuth2
    module Server

      class Error < StandardError
        attr_accessor :code, :error, :description, :uri, :state, :scope, :redirect_uri, :realm

        def initialize(code, error, description = "", options = {})
          @code         = code
          @error        = error
          @description  = description
          @uri          = options[:uri]
          @state        = options[:state]
          @realm        = options[:realm]
          @scope        = Array(options[:scope])
          @redirect_uri = Util.parse_uri(options[:redirect_uri]) if options[:redirect_uri]
          @www_authenticate = 
          @channel = if options[:www_authenticate].present?
            :www_authenticate
          elsif @redirect_uri.present?
            :query_string
          else
            :json_body
          end
        end

        def finish
          params = {
            :error             => error,
            :error_description => description,
            :error_uri         => uri,
            :state             => state,
            :scope             => scope.join(' ')
          }.delete_if do |key, value|
            value.blank?
          end
          case @channel
          when :www_authenticate
            params = params.collect do |key, value|
              "#{key}=\"#{URI.encode value.to_s}\""
            end
            [code, {'WWW-Authenticate' => "OAuth realm=\"#{realm}\" #{params.join(" ")}"}, []]
          when :query_string
            redirect_uri.query = if redirect_uri.query
              [redirect_uri.query, params.to_query].join('&')
            else
              params.to_query
            end
            response = Rack::Response.new
            response.redirect redirect_uri.to_s
            response.finish
          when :json_body
            [code, {'Content-Type' => 'application/json'}, params.to_json]
          end
        end
      end

      class Unauthorized < Error
        def initialize(error, description = "", options = {})
          super(401, error, description, options)
        end
      end

      class BadRequest < Error
        def initialize(error, description = "", options = {})
          super(400, error, description, options)
        end
      end

    end
  end
end