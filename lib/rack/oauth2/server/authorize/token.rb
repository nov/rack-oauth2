module Rack
  module OAuth2
    module Server
      class Authorize
        class Token < Abstract::Handler
          def call(env)
            @request  = Request.new env
            @response = Response.new request
            super
          end

          class Request < Authorize::Request
            def initialize(env)
              super
              @response_type = :token
              attr_missing!
            end
          end

          class Response < Authorize::Response
            attr_required :access_token, :token_type
            attr_optional :refresh_token, :expires_in, :scope

            def protocol_params
              super.merge(
                :access_token => access_token,
                :expires_in => expires_in,
                :refresh_token => refresh_token,
                :scope => Array(scope).join(' ')
              )
            end

            def protocol_params_location
              :fragment
            end
          end
        end
      end
    end
  end
end