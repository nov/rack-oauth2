module Rack
  module OAuth2
    module Server
      class Authorize
        class CodeAndToken < Abstract::Handler

          def call(env)
            @request  = Request.new(env)
            @response = Response.new(request)
            super
          end

          class Request < Authorize::Request
            def initialize(env)
              super
              @response_type = :code_and_token
              attr_missing!
            end
          end

          class Response < Token::Response
            attr_required :code

            def protocol_params
              super.merge(:code => code)
            end
          end

        end
      end
    end
  end
end