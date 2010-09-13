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
            def initialize(env)
              # TODO
            end

            def required_params
              # TODO
            end
          end

          class Response < Token::Response
          end

        end
      end
    end
  end
end