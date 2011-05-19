module Rack
  module OAuth2
    class AccessToken
      class Authenticator
        def initialize(token)
          @token = token
        end

        def filter_request(request)
          @token.authenticate(request)
        end

        def filter_response(response, request)
          # nothing to do
        end
      end
    end
  end
end