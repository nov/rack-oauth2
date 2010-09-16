module Rack
  module OAuth2
    module Server
      module Abstract
        class Handler
          attr_accessor :realm, :authenticator, :request, :response

          def initialize(realm = nil, &authenticator)
            @realm = realm
            @authenticator = authenticator
          end

          def call(env)
            @authenticator.call(@request, @response) if @authenticator
            @response
          end
        end
      end
    end
  end
end