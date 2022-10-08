module Rack
  module OAuth2
    class AccessToken
      class MTLS < Bearer
        attr_required :private_key, :certificate

        def initialize(attributes = {})
          super
          self.token_type = :bearer
          httpclient.ssl.client_key = private_key
          httpclient.ssl.client_cert = certificate
        end
      end
    end
  end
end
