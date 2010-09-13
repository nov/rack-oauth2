module Rack
  module OAuth2
    module Server
      module Profile
        module WebServer
          # == Web Server Profile - Authorize
          #
          # Required params:: response_type, client_id, redirect_uri
          # Optional params:: scope, state
          class AccessToken < Abstract

            def call(env)
              request  = Request.new(env)
              response = Response.new(request)
              response = @authenticator.call(request, response)
              response.finish || @app.call(env)
            rescue Exception => e
              e.respond
            end

            class Request < Rack::Request
              attr_reader :client_id, :redirect_uri, :grant_type, :code, :scope, :state

              def initialize(env)
                super(env)
                verify_required_params!
                @client_id    = params['client_id']
                @redirect_uri = params['redirect_uri']
                @grant_type   = params['grant_type']
                @code         = params['code']
                @scope        = params['scope']
                @state        = params['state']
              end

              def verify_required_params!
                requred_params = if params['code']
                  raise 'Implement me!'
                else
                  ['response_type', 'client_id', 'redirect_uri']
                end
                requred_params.each do |key|
                  unless params[key]
                    raise BadRequest.new(:invalid_request, "'#{key}' required")
                  end
                end
              end

            end

            class Response
              attr_accessor :code, :access_token, :redirect_uri, :expires_in, :scope, :state

              def initialize(request)
                @state = request.state
              end

              def finish
                if redirect_uri
                  [200, {'Content-Type' => "application/json"}, response.as_json]
                elsif access_token
                  [303, {'Content-Type' => 'text/html', 'Location' => redirect_uri}, []]
                end
              end
            end

          end
        end
      end
    end
  end
end