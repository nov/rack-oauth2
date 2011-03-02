require 'rack/auth/basic'

module Rack
  module OAuth2
    module Server
      class Token < Abstract::Handler

        def call(env)
          request = Request.new(env)
          request.profile.new(&@authenticator).call(env).finish
        rescue Error => e
          e.finish
        end

        class Request < Abstract::Request
          attr_required :grant_type
          attr_optional :client_secret
          attr_accessor :via_authorization_header

          def initialize(env)
            auth = Rack::Auth::Basic::Request.new(env)
            if auth.provided? && auth.basic?
              @client_id, @client_secret = auth.credentials
              @via_authorization_header = true
              super
            else
              super
              @client_secret = params['client_secret']
            end
            @grant_type = params['grant_type']
          end

          def profile
            case params['grant_type'].to_s
            when 'authorization_code'
              AuthorizationCode
            when 'password'
              Password
            when 'assertion'
              Assertion
            when 'refresh_token'
              RefreshToken
            when ''
              attr_missing!
            else
              unsupported_grant_type!("'#{params['grant_type']}' isn't supported.")
            end
          end

        end

        class Response < Abstract::Response
          attr_required :access_token
          attr_optional :expires_in, :refresh_token, :scope

          def protocol_params
            {
              :access_token => access_token,
              :expires_in => expires_in,
              :scope => Array(scope).join(' ')
            }
          end

          def finish
            _protocol_params_ = protocol_params.reject do |key, value|
              value.blank?
            end
            write _protocol_params_.to_json
            header['Content-Type'] = "application/json"
            super
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