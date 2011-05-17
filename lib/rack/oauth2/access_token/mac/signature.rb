module Rack
  module OAuth2
    class AccessToken
      class MAC
        class Signature < Verifier
          attr_required :secret, :nonce, :method, :request_uri, :host, :port
          attr_optional :body_hash, :ext, :query

          def calculate
            Rack::OAuth2::Util.base64_encode OpenSSL::HMAC.digest(
              hash_generator,
              secret,
              normalized_request_string
            )
          end

          def normalized_request_string
            [
              nonce,
              method.to_s.upcase,
              request_uri,
              host,
              port,
              body_hash || '',
              ext || '',
              nil
            ].join("\n")
          end

        end
      end
    end
  end
end
