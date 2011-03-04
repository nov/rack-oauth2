module Rack
  module OAuth2
    module Server
      class Token
        class AuthorizationCode < Abstract::Handler
          def call(env)
            @request  = Request.new(env)
            @response = Response.new(request)
            super
          end

          class Request < Token::Request
            attr_required :code

            def initialize(env)
              super
              @grant_type = :authorization_code
              @code       = params['code']
              attr_missing!
            end
          end
        end
      end
    end
  end
end