module Rack
  module OAuth2
    module Server
      class Resource
        class Mac < Resource
          def call(env)
            self.request = Request.new(env)
            super
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
            def access_token
              if @auth_header.provided? && @auth_header.scheme == :mac
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