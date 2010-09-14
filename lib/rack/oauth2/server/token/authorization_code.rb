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
            attr_accessor :code, :redirect_uri, :scope

            def initialize(env)
              super
              @grant_type   = 'authorization_code'
              @code         = params['code']
              @redirect_uri = URI.parse(params['redirect_uri'])
              @scope        = Array(params['scope'].to_s.split(' '))
            rescue URI::InvalidURIError
              raise BadRequest.new(:invalid_request, 'Invalid redirect_uri format.')
            end

            def required_params
              super + [:code, :redirect_uri]
            end
          end

          class Response < Token::Response
          end

        end
      end
    end
  end
end