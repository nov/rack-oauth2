module Rack
  module OAuth2
    module Server

      class Error < StandardError
        attr_accessor :code, :error, :description, :uri, :redirect_uri, :state

        def initialize(code, error, description = "", options = {})
          @code         = code
          @error        = error
          @description  = description
          @uri          = options[:uri]
          @state        = options[:state]
          @redirect_uri = options[:redirect_uri]
        end

        def finish
          params = {
            :error             => error,
            :error_description => description,
            :error_uri         => uri,
            :state             => state
          }.delete_if do |key, value|
            value.blank?
          end
          if redirect_uri
            _redirect_uri_ = case redirect_uri
            when URI::Generic
              redirect_uri
            when String
              URI.parse(redirect_uri)
            else
              raise "Invalid redirect_uri is given. String or URI::Generic is require."
            end
            _redirect_uri_.query = if _redirect_uri_.query
              [_redirect_uri_.query, params.to_query].join('&')
            else
              params.to_query
            end
            response = Rack::Response.new
            response.redirect _redirect_uri_.to_s
            response.finish
          else
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