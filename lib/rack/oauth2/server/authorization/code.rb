module Rack
  module OAuth2
    module Server
      class Authorization
        class Code < Abstract::Handler

          def call(env)
            @request  = Request.new(env)
            @response = Response.new(request)
            super
          end

          class Request < Authorization::Request
            def initialize(env)
              super
              @response_type = 'code'
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