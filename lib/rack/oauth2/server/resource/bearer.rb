module Rack
  module OAuth2
    module Server
      module Resource
        class Bearer < Abstract::Handler
          ACCESS_TOKEN = 'rack.oauth2.bearer.oauth_token'

          def initialize(app, &authenticator)
            @app = app
            super(&authenticator)
          end

          def call(env)
            request = Request.new(env)
            if request.bearer?
              authenticate!(request)
              env[ACCESS_TOKEN] = request.access_token
            end
            @app.call(env)
          rescue Rack::OAuth2::Server::Abstract::Error => e
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

            def bearer?
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
                invalid_request!('Both Authorization header and payload includes access token.')
              end
            end

            def access_token_in_haeder
              if @auth_header.provided? && @auth_header.scheme == :bearer
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
end

require 'rack/oauth2/server/resource/bearer/error'