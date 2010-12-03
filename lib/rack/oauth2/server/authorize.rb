module Rack
  module OAuth2
    module Server
      class Authorize < Abstract::Handler

        def call(env)
          request = Request.new(env)
          request.profile.new(@realm, &@authenticator).call(env).finish
        rescue Error => e
          e.finish
        end

        class Request < Abstract::Request
          include Error::Authorize
          attr_required :response_type
          attr_accessor :redirect_uri, :state

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
            when 'code_and_token'
              CodeAndToken
            when ''
              verify_required_params!
            else
              unsupported_response_type!("'#{params['response_type']}' isn't supported.")
            end
          end

        end

        class Response < Abstract::Response
          attr_accessor :redirect_uri, :state, :approved

          def initialize(request)
            @state = request.state
            @redirect_uri = Util.parse_uri(request.redirect_uri) if request.redirect_uri
            super
          end

          def approved?
            @approved
          end

          def approve!
            @approved = true
          end
        end

      end
    end
  end
end

require 'rack/oauth2/server/authorize/code'
require 'rack/oauth2/server/authorize/token'
require 'rack/oauth2/server/authorize/code_and_token'