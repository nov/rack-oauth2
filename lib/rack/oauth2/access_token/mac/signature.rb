module Rack
  module OAuth2
    class AccessToken
      class MAC
        class Signature < Verifier
          attr_required :token, :secret, :timestamp, :nonce, :method, :host, :port, :path
          attr_optional :body_hash, :query

          def calculate
            Rack::OAuth2::Util.base64_encode OpenSSL::HMAC.digest(
              hash_generator,
              secret,
              normalized_request_string
            )
          end

          def normalized_request_string
            [
              token,
              secret,
              algorithm,
              timestamp,
              nonce,
              body_hash,
              method,
              host,
              port,
              path,
              normalized_query
            ].join("\n")
          end

          def normalized_query
            if query.present?
              query.inject([]) do |result, (key, value)|
                result << [key, value]
              end.sort.inject('') do |result, (key, value)|
                result << "#{Rack::OAuth2::Util.rfc3986_encode key}=#{Rack::OAuth2::Util.rfc3986_encode value}\n"
              end
            else
              query.to_s
            end
          end
        end
      end
    end
  end
end