module Rack
  module OAuth2
    class Client
      class Approval
        class AuthorizationCode
          attr_required :code, :redirect_uri
        end
      end
    end
  end
end