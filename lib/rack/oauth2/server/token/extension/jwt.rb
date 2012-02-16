module Rack
  module OAuth2
    module Server
      class Token
        module Extension
          class JWT < Abstract::Handler
            GRANT_TYPE_URN = 'urn:ietf:params:oauth:grant-type:jwt-bearer'

            class << self
              def grant_type_for?(grant_type)
                grant_type == GRANT_TYPE_URN
              end
            end

            def call(env)
              @request  = Request.new env
              @response = Response.new request
              super
            end

            class Request < Token::Request
              attr_required :assertion
              attr_optional :client_id

              def initialize(env)
                super
                @grant_type = GRANT_TYPE_URN
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