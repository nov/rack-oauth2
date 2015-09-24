module Rack
  module OAuth2
    class Client
      class Grant
        class ClientCredentials < Grant
          private

          def type
            :client_credentials
          end
        end
      end
    end
  end
end