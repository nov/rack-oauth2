module Rack
  module OAuth2
    module Server
      class Token < Abstract::Handler
        attr_accessor :grant_type, :optional_authentication

        def call(env)
          request = Request.new(env)
          request.profile.new(@app, @realm, &@authenticator).call(env).finish
        rescue Error => e
          e.finish
        end

        class Request < Abstract::Request
          attr_accessor :grant_type, :client_secret

          def initialize(env)
            super
            @grant_type    = params['grant_type']
            @client_secret = params['client_secret']
          end

          def required_params
            [:grant_type, :client_id]
          end

          def profile(allow_no_profile = false)
            case params['grant_type']
            when 'authorization_code'
              AuthorizationCode
            when 'password'
              Password
            when 'assertion'
              Assertion
            when 'refresh_token'
              RefreshToken
            else
              raise BadRequest.new(:unsupported_grant_type, "'#{params['invalid_grant']}' isn't supported.")
            end
          end
        end

        class Response < Abstract::Response
          attr_accessor :access_token, :expires_in, :refresh_token, :scope

          def finish
            response = {:access_token => access_token}
            response[:expires_in] = expires_in if expires_in
            response[:refresh_token] = refresh_token if refresh_token
            response[:scope] = Array(scope).join(' ') if scope
            [200, {'Content-Type' => "application/json"}, response.to_json]
          end
        end

      end
    end
  end
end

require 'rack/oauth2/server/token/authorization_code'
require 'rack/oauth2/server/token/password'
require 'rack/oauth2/server/token/assertion'
require 'rack/oauth2/server/token/refresh_token'