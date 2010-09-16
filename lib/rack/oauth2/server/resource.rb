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

          def initialize(env)
            @env = env
            @auth_header = Rack::Auth::AbstractRequest.new(env)
          end

          def oauth2?
            access_token.present?
          end

          def access_token
            @access_token ||= case
            when access_token_in_haeder.present? && access_token_in_payload.blank?
              access_token_in_haeder
            when access_token_in_haeder.blank? && access_token_in_payload.present?
              access_token_in_payload
            when access_token_in_haeder.present? && access_token_in_payload.present?
              raise BadRequest.new(:invalid_request, 'Both Authorization header and payload includes oauth_token.', :www_authenticate => true)
            else
              nil
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