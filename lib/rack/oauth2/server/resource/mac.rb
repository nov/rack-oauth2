module Rack
  module OAuth2
    module Server
      class Resource
        class Mac < Resource
          def call(env)
            super do
              request = Request.new(env)
              if request.mac?
                authenticate!(request)
                env[ACCESS_TOKEN] = request.access_token
              end
            end
          end

          private

          def authenticate!(request)
            verify_signature!(request)
            super
          end

          def verify_signature!(request)
            # TODO
          end

          class Request < Resource::Request
            def mac?
              access_token.present?
            end

            def scheme
              :mac
            end

            def access_token
              if @auth_header.provided? && @auth_header.scheme == scheme
                @auth_header.params
              else
                nil
              end
            end
          end
        end
      end
    end
  end
end

require 'rack/oauth2/server/resource/mac/error'