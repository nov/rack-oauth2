module Rack
  module OAuth2
    module Server
      class Resource
        class Bearer < Resource
          def call(env)
            self.request = Request.new(env)
            super
          end

          private

          class Request < Resource::Request
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
              params['bearer_token']
            end
          end
        end
      end
    end
  end
end

require 'rack/oauth2/server/resource/bearer/error'