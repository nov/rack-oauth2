module Rack
  module OAuth2
    module Server
      class Authorization
        # == Web Server Profile - Authorize
        #
        # Required params:: response_type, client_id, redirect_uri
        # Optional params:: scope, state
        class WebServer < Abstract::Handler

          def call(env)
            @request  = Request.new(env)
            @response = Response.new(request)
            super
          end

          class Request < Authorization::Request
            attr_reader :client_id, :redirect_uri, :scope, :state

            def initialize(env)
              super
              @response_type = 'code'
              @client_id     = params['client_id']
              @redirect_uri  = URI.parse(params['redirect_uri']) rescue nil
              @redirect_uri  = nil unless @redirect_uri.scheme
              @scope         = Array(params['scope'].to_s.split(' '))
              @state         = params['state']
            end

            def requred_params
              [:response_type, :client_id, :redirect_uri]
            end
          end

          class Response < Authorization::Response
            attr_accessor :code

            def finish
              if approved?
                query_params = Array(redirect_uri.query)
                query_params << "code=#{URI.encode code}"
                query_params << "state=#{URI.encode state}" if state
                redirect_uri.query = query_params.join('&')
                redirect redirect_uri.to_s
              end
              super
            end
          end

        end
      end
    end
  end
end