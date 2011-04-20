module Rack
  module OAuth2
    class AccessToken
      class MAC
        class BodyHash < Verifier
          attr_optional :raw_body

          def calculate
            Rack::OAuth2::Util.base64_encode hash_generator.digest(raw_body)
          end
        end
      end
    end
  end
end