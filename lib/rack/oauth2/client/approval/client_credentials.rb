module Rack
  module OAuth2
    class Client
      class Approval
        class ClientCredentials < Approval
          attr_required :identifier, :secret
        end
      end
    end
  end
end
