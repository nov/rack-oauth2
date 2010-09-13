module Rack
  module OAuth2
    module Server
      class Authorization
        class CodeAndToken < Abstract::Handler

          def call(env)
            @request  = Request.new(env)
            @response = Response.new(request)
            super
          end

          class Request < Authorization::Request
            def initialize(env)
              super
              # TODO
            end

            def requred_params
              # TODO
            end
          end

          class Response < Authorization::Response
            def finish
              if approved?
                # TODO
              end
              super
            end
          end

        end
      end
    end
  end
end