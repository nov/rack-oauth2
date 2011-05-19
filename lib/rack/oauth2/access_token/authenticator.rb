module Rack
  module OAuth2
    class AccessToken
      class Authenticator
        def initialize(token)
          @token = token
        end

        def filter_request(request)
          raise "filter"
          @token.authenticate(request)
        end
      end
    end
  end
end