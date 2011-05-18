module Rack
  module OAuth2
    class AccessToken
      class Legacy < AccessToken
        def initialize(attributes = {})
          super
          self.expires_in = self.expires_in.try(:to_i)
        end

        def to_s # This is for fb_graph
          self.access_token
        end

        private
        def authenticate(headers)
          headers.merge(:AUTHORIZATION => "OAuth2 #{access_token}")
        end
      end
    end
  end
end