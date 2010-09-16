require 'rack/auth/abstract/request'

module Rack
  module OAuth2
    module Server
      class Resource < Abstract::Handler

        def initialize(app, realm=nil, &authenticator)
          @app = app
          super(realm, &authenticator)
        end

        def call(env)
          request = Request.new(env)
          if request.oauth2?
            authenticate!(request)
            env[OAUTH_TOKEN] = request.oauth_token
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

          def initialize(env)
            @env = env
            @auth_header = Rack::Auth::AbstractRequest.new(env)
          end

          def oauth2?
            oauth_token.present?
          end

          def oauth_token
            @oauth_token ||= case
            when oauth_token_in_haeder.present? && oauth_token_in_payload.blank?
              oauth_token_in_haeder
            when oauth_token_in_haeder.blank? && oauth_token_in_payload.present?
              oauth_token_in_payload
            when oauth_token_in_haeder.present? && oauth_token_in_payload.present?
              raise BadRequest.new(:invalid_request, 'Both Authorization header and payload includes oauth_token.', :www_authenticate => true)
            else
              nil
            end
          end

          def oauth_token_in_haeder
            if @auth_header.provided? && @auth_header.scheme == :oauth && @auth_header.params !~ /oauth_signature_method/
              @auth_header.params
            else
              nil
            end
          end

          def oauth_token_in_payload
            if params['access_token'] && !params['oauth_signature_method']
              params['access_token']
            else
              nil # This is OAuth1 request
            end
          end

        end

      end
    end
  end
end