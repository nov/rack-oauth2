module Rack
  module OAuth2
    module Server

      class Error < StandardError
        attr_accessor :code, :error, :description, :uri, :state

        def initialize(code, error, description, options = {})
          @code = code
          @error = error
          @description = description
          @uri = options[:uri]
          @state = options[:state]
        end

        def finish
          [code, {'Content-Type' => 'application/json'}, response.to_json]
        end

        def response
          response = {:error => error}
          response[:error_description] = description if description
          response[:error_uri] = uri if uri
          response[:state] = state if state
          response
        end
      end

      class Unauthorized < Error
        def initialize(error, description, options = {})
          super(401, error, description, options)
        end
      end

      class BadRequest < Error
        def initialize(error, description, options = {})
          super(400, error, description, options)
        end
      end

    end
  end
end