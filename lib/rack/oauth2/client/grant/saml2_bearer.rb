module Rack
  module OAuth2
    class Client
      class Grant
        class SAML2Bearer < Grant
          attr_required :assertion

          def grant_type
            'urn:ietf:params:oauth:grant-type:saml2-bearer'
          end
        end
      end
    end
  end
end