module Rack
  module OAuth2
    class Client
      class Approval
        class ResourceOwnerCredentials < Approval
          attr_required :username, :password
        end
      end
    end
  end
end