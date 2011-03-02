module Rack
  module OAuth2
    module Server
      module Abstract
        class Error < StandardError
          attr_accessor :status, :error, :description, :uri

          def initialize(status, error, description = nil, options = {})
            @status       = status
            @error        = error
            @description  = description
            @uri          = options[:uri]
          end

          def protocol_params
            {
              :error             => error,
              :error_description => description,
              :error_uri         => uri
            }
          end

          def finish
            response = Rack::Response.new
            yield response if block_given?
            response.finish
          end
        end

        class BadRequest < Error
          def initialize(error, description = nil, options = {})
            super 400, error, description, options
          end
        end

        class Unauthorized < Error
          def initialize(error, description = nil, options = {})
            super 401, error, description, options
          end
        end

        class Forbidden < Error
          def initialize(error, description = nil, options = {})
            super 403, error, description, options
          end
        end
      end
    end
  end
end