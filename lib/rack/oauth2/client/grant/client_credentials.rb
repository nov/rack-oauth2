module Rack
  module OAuth2
    class Client
      class Grant
        class ClientCredentials < Grant
          attr_optional :scope
        end
      end
    end
  end
end