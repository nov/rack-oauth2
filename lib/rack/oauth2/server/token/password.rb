module Rack
  module OAuth2
    module Server
      class Token
        class Password < Abstract::Handler

          def call(env)
            @request  = Request.new(env)
            @response = Response.new(request)
            super
          end

          class Request < Token::Request
            attr_reader :username, :password

            def initialize(env)
              super
              @grant_type = 'password'
              @username   = params['username']
              @password   = params['password']
            end

            def required_params
              super + [:username, :password]
            end
          end

          class Response < Token::Response
          end

        end
      end
    end
  end
end