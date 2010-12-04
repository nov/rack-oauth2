module Rack
  module OAuth2
    module Server
      class Authorize
        class Code < Abstract::Handler

          def call(env)
            @request  = Request.new(env)
            @response = Response.new(request)
            super
          end

          class Request < Authorize::Request
            def initialize(env)
              super
              @response_type = :code
              attr_missing!
            end
          end

          class Response < Authorize::Response
            attr_required :code

            def finish
              if approved?
                params = {
                  :code => code,
                  :state => state
                }.delete_if do |key, value|
                  value.blank?
                end
                redirect_uri.query = if redirect_uri.query
                  [redirect_uri.query, params.to_query].join('&')
                else
                  params.to_query
                end
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