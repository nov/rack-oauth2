module Rack
  module OAuth2
    class Client
      class Error < StandardError
        attr_accessor :status, :response
        def initialize(status, response)
          @status = status
          @response = response
          super response[:error_description]
        end
      end
    end
  end
end