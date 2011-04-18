module Rack
  module OAuth2
    class AccessToken
      class Bearer < AccessToken
        def get(url, headers = {}, &block)
          RestClient.get url, authenticate(headers), &block
        end

        def post(url, payload, headers = {}, &block)
          RestClient.post url, payload, authenticate(headers), &block
        end

        def put(url, payload, headers = {}, &block)
          RestClient.put url, payload, authenticate(headers), &block
        end

        def delete(url, headers = {}, &block)
          RestClient.delete url, authenticate(headers), &block
        end

        private

        def authenticate(headers)
          headers.merge(:HTTP_AUTHORIZATION => "Bearer #{access_token}")
        end
      end
    end
  end
end