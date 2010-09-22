module Rack
  module OAuth2
    module Server

      class Error < StandardError
        attr_accessor :status, :error, :description, :uri, :state, :scope, :redirect_uri, :realm

        def initialize(status, error, description = "", options = {})
          @status       = status
          @error        = error
          @description  = description
          @uri          = options[:uri]
          @state        = options[:state]
          @realm        = options[:realm]
          @scope        = Array(options[:scope])
          @redirect_uri = Util.parse_uri(options[:redirect_uri]) if options[:redirect_uri]
          @www_authenticate = options[:www_authenticate].present?
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
          response = Rack::Response.new
          if @redirect_uri.present?
            redirect_uri.query = if redirect_uri.query
              [redirect_uri.query, params.to_query].join('&')
            else
              params.to_query
            end
            response.redirect redirect_uri.to_s
          else
            response.status = status
            response.header['Content-Type'] = 'application/json'
            if @www_authenticate
              response.header['WWW-Authenticate'] = "OAuth realm='#{realm}' #{params.collect { |key, value| "#{key}='#{value.to_s}'" }.join(' ')}"
            end
            response.write params.to_json
          end
          response.finish
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