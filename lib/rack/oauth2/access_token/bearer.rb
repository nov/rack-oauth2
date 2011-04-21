module Rack
  module OAuth2
    class AccessToken
      class Bearer < AccessToken
        private
        def authenticate(headers)
          headers.merge(:AUTHORIZATION => "Bearer #{access_token}")
        end
      end
    end
  end
end