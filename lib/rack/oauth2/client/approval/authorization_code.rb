module Rack
  module OAuth2
    class Client
      class Approval
        class AuthorizationCode < Approval
          attr_required :code, :redirect_uri
        end
      end
    end
  end
end