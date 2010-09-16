module Rack
  module OAuth2
    module Server
      class Token
        class RefreshToken < Abstract::Handler

          def call(env)
            @request  = Request.new(env)
            @response = Response.new(request)
            super
          end

          class Request < Token::Request
            attr_reader :refresh_token

            def initialize(env)
              super
              @grant_type    = 'refresh_token'
              @refresh_token = params['refresh_token']
            end

            def required_params
              super + [:refresh_token]
            end
          end

        end
      end
    end
  end
end