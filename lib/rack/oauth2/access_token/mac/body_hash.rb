module Rack
  module OAuth2
    class AccessToken
      class MAC
        class BodyHash < Verifier
          attr_required :raw_body

          def initialize(payload = {})
            # FIXME: Use raw body here!
            @raw_body = payload.to_query
            attr_missing!
          end

          def calculate
            Base64.encode64 hash_generator.digest(raw_body)
          end
        end
      end
    end
  end
end