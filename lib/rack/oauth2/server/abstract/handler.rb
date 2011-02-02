module Rack
  module OAuth2
    module Server
      module Abstract
        class Handler
          attr_accessor :authenticator, :request, :response

          def initialize(&authenticator)
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