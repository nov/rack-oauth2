module Rack
  module OAuth2
    module Server
      module Profile
        module WebServer
          # == Web Server Profile - Authorize
          #
          # Required params:: response_type, client_id, redirect_uri
          # Optional params:: scope, state
          class Authorize < Abstract

            def call(env)
              request  = Request.new(env)
              response = Response.new(request)
              response = @authenticator.call(request, response)
              env['rack.oauth2.request'] = request
              env['rack.oauth2.response'] = response
              response.finish || @app.call(env)
            rescue Exception => e
              e.respond
            end

            class Request < Rack::Request
              attr_reader :client_id, :redirect_uri, :scope, :state

              def initialize(env)
                super(env)
                verify_required_params!
                @client_id    = params['client_id']
                @redirect_uri = URI.parse(params['redirect_uri']) rescue nil
                @redirect_uri = nil unless @redirect_uri.scheme
                @scope        = Array(params['scope'].to_s.split(' '))
                @state        = params['state']
              end

              def verify_required_params!
                requred_params = ['response_type', 'client_id', 'redirect_uri']
                requred_params.each do |key|
                  unless params[key]
                    raise BadRequest.new(:invalid_request, "'#{key}' required")
                  end
                end
              end

            end

            class Response
              attr_accessor :code, :redirect_uri, :state, :approved

              def initialize(request)
                @redirect_uri = request.redirect_uri
                @state = request.state
              end

              def finish
                if approved
                  query_params = Array(@redirect_uri.query)
                  query_params << "code=#{code}"
                  query_params << "state=#{state}" if state
                  redirect_uri.query = query_params.join('&')
                  [303, {'Content-Type' => 'text/html', 'Location' => redirect_uri.to_s}, []]
                end
              end

            end

          end
        end
      end
    end
  end
end