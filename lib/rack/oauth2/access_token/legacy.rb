module Rack
  module OAuth2
    class AccessToken
      class Legacy < AccessToken
        def initialize(attributes = {})
          super
          self.expires_in = (
            self.expires_in ||
            attributes[:expires]
          )&.to_i
        end

        def authenticate(request)
          request.headers["Authorization"] = "OAuth #{access_token}"
        end
      end
    end
  end
end