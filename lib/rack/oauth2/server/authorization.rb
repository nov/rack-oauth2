module Rack
  module OAuth2
    module Server
      class Authorization < Abstract::Handler

        def call(env)
          request = Request.new(env)
          request.profile.new(@app, @realm, &@authenticator).call(env).finish
        rescue Error => e
          e.finish
        end

        class Request < Abstract::Request
          attr_accessor :response_type

          def profile
            case params['response_type']
            when 'code'
              WebServer
            when 'token'
              UserAgent
            when 'token_and_code'
              raise BadRequest.new(:unsupported_response_type, 'This profile is pending.')
            else
              raise BadRequest.new(:unsupported_response_type, "'#{params['response_type']}' isn't supported.")
            end
          end

          def required_params
            [:response_type, :client_id, :redirect_uri]
          end
        end

        class Response < Abstract::Response
          attr_accessor :redirect_uri, :state, :approved

          def initialize(request)
            @redirect_uri = request.redirect_uri
            @state = request.state
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

require 'rack/oauth2/server/authorization/web_server'
require 'rack/oauth2/server/authorization/user_agent'