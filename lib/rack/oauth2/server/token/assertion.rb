module Rack
  module OAuth2
    module Server
      class Token
        class Assertion < Abstract::Handler

          def call(env)
            @request  = Request.new(env)
            @response = Response.new(request)
            super
          end

          class Request < Token::Request
            attr_required :assertion_type, :assertion

            def initialize(env)
              super
              @grant_type     = 'assertion'
              @assertion_type = params['assertion_type']
              @assertion      = params['assertion']
              attr_missing!
            end
          end

        end
      end
    end
  end
end