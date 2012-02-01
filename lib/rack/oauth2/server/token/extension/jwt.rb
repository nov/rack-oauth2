module Rack
  module OAuth2
    module Server
      class Token
        module Extension
          class JWT < Abstract::Handler
            class << self
              def grant_type_for?(grant_type)
                grant_type == 'urn:ietf:params:oauth:grant-type:jwt-bearer'
              end
            end

            def call(env)
              @request  = Request.new env
              @response = Response.new request
              super
            end

            class Request < Authorize::Token::Request
              attr_required :assertion

              def initialize(env)
                super
                @grant_type = :jwt
                @assertion = params['assertion']
                attr_missing!
              end
            end
          end
        end
      end
    end
  end
end