require 'rack/auth/basic'

module Rack
  module OAuth2
    module Server
      class Token < Abstract::Handler
        def call(env)
          request = Request.new(env)
          grant_type_for(request).new(&@authenticator).call(env).finish
        rescue Rack::OAuth2::Server::Abstract::Error => e
          e.finish
        end

        private

        def grant_type_for(request)
          case request.grant_type
          when 'authorization_code'
            AuthorizationCode
          when 'password'
            Password
          when 'client_credentials'
            ClientCredentials
          when 'refresh_token'
            RefreshToken
          when ''
            request.attr_missing!
          else
            extensions.detect do |extension|
              extension.grant_type_for? request.grant_type
            end || request.unsupported_grant_type!
          end
        end

        def extensions
          Extension.constants.sort.collect do |key|
            Extension.const_get key
          end
        end

        class Request < Abstract::Request
          attr_required :grant_type
          attr_optional :client_secret

          def initialize(env)
            auth = Rack::Auth::Basic::Request.new(env)
            if auth.provided? && auth.basic?
              @client_id, @client_secret = auth.credentials
              super
            else
              super
              @client_secret = params['client_secret']
            end
            @grant_type = params['grant_type'].to_s
          end
        end

        class Response < Abstract::Response
          attr_required :access_token

          def protocol_params
            access_token.token_response
          end

          def finish
            attr_missing!
            write MultiJson.dump(Util.compact_hash(protocol_params))
            header['Content-Type'] = 'application/json'
            header['Cache-Control'] = 'no-store'
            header['Pragma'] = 'no-cache'
            super
          end
        end
      end
    end
  end
end

require 'rack/oauth2/server/token/authorization_code'
require 'rack/oauth2/server/token/password'
require 'rack/oauth2/server/token/client_credentials'
require 'rack/oauth2/server/token/refresh_token'
require 'rack/oauth2/server/token/extension'
require 'rack/oauth2/server/token/error'