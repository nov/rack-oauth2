module Rack
  module OAuth2
    module Server
      class Token < Abstract::Handler
        attr_accessor :optional_authentication

        def call(env)
          # TODO
        end

        class Request < Abstract::Request
          def profile(allow_no_profile = false)
            # TODO
          end

          def required_params
            # TODO
          end
        end

        class Response < Abstract::Response
        end

      end
    end
  end
end

require 'rack/oauth2/server/token/web_server'