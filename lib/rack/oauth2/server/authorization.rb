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
          attr_accessor :response_type, :client_id, :redirect_uri, :scope, :state

          def initialize(env)
            super
            @redirect_uri = URI.parse(params['redirect_uri'])
            @state        = params['state']
          rescue URI::InvalidURIError
            # NOTE: can't redirect in this case.
            raise BadRequest.new(:invalid_request, 'Invalid redirect_uri format.')
          end

          def required_params
            [:response_type, :client_id, :redirect_uri]
          end

          def profile
            case params['response_type']
            when 'code'
              Code
            when 'token'
              Token
            when 'token_and_code'
              CodeAndToken
            else
              raise BadRequest.new(:unsupported_response_type, "'#{params['response_type']}' isn't supported.", :state => state, :redirect_uri => redirect_uri)
            end
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

require 'rack/oauth2/server/authorization/code'
require 'rack/oauth2/server/authorization/token'