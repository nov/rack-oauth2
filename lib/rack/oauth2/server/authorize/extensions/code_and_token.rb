module Rack
  module OAuth2
    module Server
      class Authorize
        module Extensions
          class CodeAndToken < Abstract::Handler
            class << self
              def response_type_for?(response_type)
                response_type.split.sort == ['code', 'token']
              end
            end

            def call(env)
              @request  = Request.new env
              @response = Response.new request
              super
            end

            class Request < Authorize::Token::Request
              def initialize(env)
                super
                @response_type = [:code, :token]
                attr_missing!
              end
            end

            class Response < Authorize::Token::Response
              attr_required :code

              def redirect_uri_with_credentials
                Util.redirect_uri(super, :query, :code => code)
              end
            end
          end
        end
      end
    end
  end
end