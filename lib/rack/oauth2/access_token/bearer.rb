module Rack
  module OAuth2
    class AccessToken
      class Bearer < AccessToken
        def authenticate(request)
          request.header["Authorization"] = "Bearer #{access_token}"
        end

        private

        def type
          :bearer
        end
      end
    end
  end
end