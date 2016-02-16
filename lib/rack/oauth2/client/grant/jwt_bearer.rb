module Rack
  module OAuth2
    class Client
      class Grant
        class JWTBearer < Grant
          attr_required :assertion

          def grant_type
            'urn:ietf:params:oauth:grant-type:jwt-bearer'
          end
        end
      end
    end
  end
end