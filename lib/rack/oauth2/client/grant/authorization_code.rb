module Rack
  module OAuth2
    class Client
      class Grant
        class AuthorizationCode < Grant
          attr_required :code, :redirect_uri
        end
      end
    end
  end
end