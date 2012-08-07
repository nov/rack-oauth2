module Rack
  module OAuth2
    class AccessToken
      class MAC < AccessToken
        attr_required :mac_key, :mac_algorithm
        attr_optional :ts, :ext_verifier
        attr_reader :nonce, :signature, :ext

        def initialize(attributes = {})
          super(attributes)
        end

        def token_response
          super.merge(
            :mac_key => mac_key,
            :mac_algorithm => mac_algorithm
          )
        end

        def verify!(request)          
          body = request.body.read
          if self.ext_verifier.present?
            self.ext_verifier.new(
              :raw_body => body,
              :algorithm => self.mac_algorithm
            ).verify!(request.ext)
          end

          Signature.new(
            :secret      => self.mac_key,
            :algorithm   => self.mac_algorithm,
            :nonce       => request.nonce,
            :method      => request.request_method,
            :request_uri => request.fullpath,
            :host        => request.host,
            :port        => request.port,
            :ts          => request.ts,
            :ext         => request.ext
          ).verify!(request.signature)
        rescue Verifier::VerificationFailed => e
          request.invalid_token! e.message
        end

        def authenticate(request)
          @nonce = generate_nonce

          if self.ext_verifier.present?
            @ext = self.ext_verifier.new(
              :raw_body => request.body,
              :algorithm => self.mac_algorithm
            ).calculate
          end

          @signature = Signature.new(
            :secret      => self.mac_key,
            :algorithm   => self.mac_algorithm,
            :nonce       => self.nonce,
            :method      => request.header.request_method,
            :request_uri => request.header.create_query_uri,
            :host        => request.header.request_uri.host,
            :port        => request.header.request_uri.port,
            :ts          => self.ts || Time.now.utc,
            :ext         => @ext
          ).calculate

          request.header['Authorization'] = authorization_header
        end

        private

        def authorization_header
          header = "MAC id=\"#{access_token}\""
          header << ", nonce=\"#{nonce}\""
          header << ", ts=\"#{ts.to_i}\""
          header << ", mac=\"#{signature}\""
          header << ", ext=\"#{ext}\"" if @ext.present?
          header
        end

        def generate_nonce
          [
            (Time.now.utc - @ts).to_i,
            SecureRandom.hex
          ].join(':')
        end
      end
    end
  end
end

require 'rack/oauth2/access_token/mac/verifier'
require 'rack/oauth2/access_token/mac/sha256_hex_verifier'
require 'rack/oauth2/access_token/mac/signature'
