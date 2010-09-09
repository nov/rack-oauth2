module Rack
  module OAuth2
    module Server

      class Exception < StandardError
        attr_accessor :code, :error, :description, :uri, :state

        def initialize(code, error, description, options = {})
          @code = code
          @error = error
          @description = description
          @uri = options[:uri]
          @state = options[:state]
        end

        def respond
          [code, {'Content-Type' => 'application/json'}, as_json]
        end

        def as_json
          {
            :error => error,
            :error_description => description,
            :error_uri => uri,
            :state => state
          }.delete_if do |k, v|
            v.nil?
          end.to_json
        end
      end

      class Unauthorized < Exception
        def initialize(error, description, options = {})
          super(401, error, description, options)
        end
      end

      class BadRequest < Exception
        def initialize(error, description, options = {})
          super(400, error, description, options)
        end
      end

    end
  end
end