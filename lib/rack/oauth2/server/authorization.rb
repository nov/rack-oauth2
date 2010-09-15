module Rack
  module OAuth2
    module Server
      class Authorization < Abstract::Handler

        def call(env)
          request = Request.new(env)
          request.profile.new(@realm, &@authenticator).call(env).finish
        rescue Error => e
          e.finish
        end

        class Request < Abstract::Request
          attr_accessor :response_type, :client_id, :redirect_uri, :state

          def initialize(env)
            super
            @redirect_uri = Util.parse_uri(params['redirect_uri']) if params['redirect_uri']
            @state        = params['state']
          end

          def required_params
            super + [:response_type, :client_id]
          end

          def profile
            case params['response_type']
            when 'code'
              Code
            when 'token'
              Token
            when 'code_and_token'
              CodeAndToken
            else
              raise BadRequest.new(:unsupported_response_type, "'#{params['response_type']}' isn't supported.", :state => state, :redirect_uri => redirect_uri)
            end
          end
        end

        class Response < Abstract::Response
          attr_accessor :redirect_uri, :state, :approved

          def initialize(request)
            @redirect_uri = Util.parse_uri(request.redirect_uri) if request.redirect_uri
            @state        = request.state
            super
          end

          def approved?
            @approved
          end

          def approve!
            @approved = true
          end
        end

      end
    end
  end
end

require 'rack/oauth2/server/authorization/code'
require 'rack/oauth2/server/authorization/token'
require 'rack/oauth2/server/authorization/code_and_token'