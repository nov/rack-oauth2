module Rack
  module OAuth2
    module Server
      class Token
        # == Web Server Profile - Access Token
        #
        # Required params:: response_type, client_id, redirect_uri
        # Optional params:: scope, state
        class WebServer < Abstract::Handler

          def call(env)
            @request  = Request.new(env)
            @response = Response.new(request)
            super
          end

          class Request < Token::Request
            attr_reader :client_id, :client_secret, :grant_type, :scope, :code, :redirect_uri

            def initialize(env)
              # TODO
            end

            def requred_params
              # TODO
            end
          end

          class Response < Token::Response
            attr_accessor :access_token, :expires_in, :refresh_token, :scope

            def finish
              response = {:access_token => access_token}
              response[:expires_in] = expires_in if expires_in
              response[:refresh_token] = refresh_token if refresh_token
              response[:scope] = Array(scope).join(' ') if scope
              [200, {'Content-Type' => "application/json"}, response.to_json]
            end
          end

        end
      end
    end
  end
end