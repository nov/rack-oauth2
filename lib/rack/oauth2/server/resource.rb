require 'rack/auth/abstract/request'

module Rack
  module OAuth2
    module Server
      class Resource < Abstract::Handler

        def initialize(app, realm = nil, &authenticator)
          @app = app
          super(realm, &authenticator)
        end

        def call(env)
          request = Request.new(env, realm)
          if request.oauth2?
            authenticate!(request)
            env[ACCESS_TOKEN] = request.access_token
          end
          @app.call(env)
        rescue Error => e
          e.realm = realm
          e.finish
        end

        private

        def authenticate!(request)
          @authenticator.call(request)
        end

        class Request < Rack::Request
          include Error::Resource

          attr_accessor :realm

          def initialize(env, realm)
            @env = env
            @realm = realm
            @auth_header = Rack::Auth::AbstractRequest.new(env)
          end

          def oauth2?
            access_token.present?
          end

          def access_token
            tokens = [access_token_in_haeder, access_token_in_payload].compact
            case Array(tokens).size
            when 0
              nil
            when 1
              tokens.first
            else
              invalid_request!('Both Authorization header and payload includes oauth_token.', :realm => realm)
            end
          end

          def access_token_in_haeder
            if @auth_header.provided? && @auth_header.scheme == :oauth && @auth_header.params !~ /oauth_signature_method/
              @auth_header.params
            else
              nil
            end
          end

          def access_token_in_payload
            if params['oauth_token'] && !params['oauth_signature_method']
              params['oauth_token']
            else
              nil # This is OAuth1 request
            end
          end

        end

      end
    end
  end
end