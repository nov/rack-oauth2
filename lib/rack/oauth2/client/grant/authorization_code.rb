module Rack
  module OAuth2
    class Client
      class Grant
        class AuthorizationCode < Grant
          attr_required :code
          attr_optional :redirect_uri

          private

          def type
            :authorization_code
          end
        end
      end
    end
  end
end