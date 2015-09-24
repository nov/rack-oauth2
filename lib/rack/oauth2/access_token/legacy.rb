module Rack
  module OAuth2
    class AccessToken
      class Legacy < AccessToken
        def initialize(attributes = {})
          super
          self.expires_in ||= attributes[:expires] ? attributes[:expires].to_i : nil
        end

        def authenticate(request)
          request.header["Authorization"] = "OAuth #{access_token}"
        end

        private

        def type
          :legacy
        end
      end
    end
  end
end