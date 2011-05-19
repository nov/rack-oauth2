module Rack
  module OAuth2
    class AccessToken
      class Bearer < AccessToken
        def authenticate(headers)
          request.header["Authorization"] = "Bearer #{access_token}"
        end
      end
    end
  end
end