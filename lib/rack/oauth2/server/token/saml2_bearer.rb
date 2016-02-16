module Rack
  module OAuth2
    module Server
      class Token
        class SAML2Bearer < Abstract::Handler
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
              @grant_type = 'urn:ietf:params:oauth:grant-type:saml2-bearer'
              @assertion = params['assertion']
              attr_missing!
            end
          end
        end
      end
    end
  end
end