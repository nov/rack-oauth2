module Rack
  module OAuth2
    module Server
      class Authorize < Abstract::Handler
        def call(env)
          request = Request.new(env)
          request.profile.new(&@authenticator).call(env).finish
        rescue BadRequest => e
          e.finish
        end

        class Request < Abstract::Request
          attr_required :response_type
          attr_optional :redirect_uri, :state

          def initialize(env)
            super
            @redirect_uri = Util.parse_uri(params['redirect_uri']) if params['redirect_uri']
            @state = params['state']
          end

          def profile
            case params['response_type'].to_s
            when 'code'
              Code
            when 'token'
              Token
            when ''
              attr_missing!
            else
              unsupported_response_type! "#{CGI.escape params['response_type']} isn't supported."
            end
          end
        end

        class Response < Abstract::Response
          attr_required :redirect_uri
          attr_optional :state, :approval

          def initialize(request)
            @state = request.state
            super
          end

          def approved?
            @approval
          end

          def approve!
            @approval = true
          end

          def protocol_params
            {:state => state}
          end

          def protocol_params_location
            raise 'Define me in subclasses'
          end

          def finish
            if approved?
              attr_missing!
              redirect Util.redirect_uri(redirect_uri, protocol_params_location, protocol_params)
            end
            super
          end
        end
      end
    end
  end
end

require 'rack/oauth2/server/authorize/code'
require 'rack/oauth2/server/authorize/token'
require 'rack/oauth2/server/authorize/error'