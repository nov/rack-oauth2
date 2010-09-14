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
                params = {
                  :code => code,
                  :state => state
                }.delete_if do |key, value|
                  value.blank?
                end
                redirect_uri.query = [redirect_uri.query, params.to_query].join('&')
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