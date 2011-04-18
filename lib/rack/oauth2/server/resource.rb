module Rack
  module OAuth2
    module Server
      class Resource < Abstract::Handler
        ACCESS_TOKEN = 'rack.oauth2.access_token'
        DEFAULT_REALM = 'Protected by OAuth 2.0'
        attr_accessor :realm, :request

        def initialize(app, realm = nil, &authenticator)
          @app = app
          @realm = realm
          super &authenticator
        end

        def call(env)
          if request.oauth2?
            authenticate!(request)
            env[ACCESS_TOKEN] = request.access_token
          end
          @app.call(env)
        rescue Rack::OAuth2::Server::Abstract::Error => e
          e.realm ||= realm
          e.finish
        end

        private

        def authenticate!(request)
          @authenticator.call(request)
        end

        class Request < Rack::Request
          def initialize(env)
            @env = env
            @auth_header = Rack::Auth::AbstractRequest.new(env)
          end

          def oauth2?
            access_token.present?
          end

          def access_token
            raise 'Define me!'
          end
        end
      end
    end
  end
end

require 'rack/oauth2/server/resource/error'
require 'rack/oauth2/server/resource/bearer'
require 'rack/oauth2/server/resource/mac'