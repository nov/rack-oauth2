module Rack
  module OAuth2
    class AccessToken
      class MAC < AccessToken
        attr_required :mac_key, :mac_algorithm
        attr_optional :issued_at, :ext
        attr_reader :nonce, :body_hash, :signature

        def initialize(attributes = {})
          super(attributes)
          @issued_at ||= Time.now.utc
        end

        def token_response
          super.merge(
            :mac_key => mac_key,
            :mac_algorithm => mac_algorithm
          )
        end

        def verify!(request)
          if request.body_hash.present?
            _body_hash_ = BodyHash.new(
              :raw_body  => request.body.read,
              :algorithm => self.mac_algorithm
            )
            _body_hash_.verify!(request.body_hash)
          end
          _signature_ = Signature.new(
            :secret      => self.mac_key,
            :algorithm   => self.mac_algorithm,
            :nonce       => request.nonce,
            :method      => request.request_method,
            :request_uri => request.fullpath,
            :host        => request.host,
            :port        => request.port,
            :body_hash   => request.body_hash,
            :ext         => request.ext
          )
          _signature_.verify!(request.signature)
        rescue Verifier::VerificationFailed => e
          request.invalid_token! e.message
        end

        def get(url, headers = {}, &block)
          _headers_ = authenticate(:get, url, headers)
          RestClient.get url, _headers_, &block
        end

        def post(url, payload, headers = {}, &block)
          _headers_ = authenticate(:post, url, headers, payload)
          RestClient.post url, payload, _headers_, &block
        end

        def put(url, payload, headers = {}, &block)
          _headers_ = authenticate(:put, url, headers, payload)
          RestClient.put url, payload, _headers_, &block
        end

        def delete(url, headers = {}, &block)
          _headers_ = authenticate(:delete, url, headers)
          RestClient.delete url, _headers_, &block
        end

        private

        def authenticate(method, url, headers = {}, payload = {})
          _url_ = URI.parse(url)
          @nonce = generate_nonce
          if payload.present?
            raw_body = RestClient::Payload.generate(payload).to_s
            _body_hash_ = BodyHash.new(
              :raw_body => raw_body,
              :algorithm => self.mac_algorithm
            )
            @body_hash = _body_hash_.calculate
          end
          _signature_ = Signature.new(
            :secret      => self.mac_key,
            :algorithm   => self.mac_algorithm,
            :nonce       => self.nonce,
            :method      => method,
            :request_uri => _url_.request_uri,
            :host        => _url_.host,
            :port        => _url_.port,
            :body_hash   => self.body_hash,
            :ext         => self.ext
          )
          @signature = _signature_.calculate
          headers.merge(:AUTHORIZATION => authorization_header)
        end

        def authorization_header
          header = "MAC"
          header << " id=\"#{access_token}\","
          header << " nonce=\"#{nonce}\","
          header << " bodyhash=\"#{body_hash}\"," if body_hash.present?
          header << " ext=\"#{ext}\"," if ext.present?
          header << " mac=\"#{signature}\""
        end

        def generate_nonce
          [
            (Time.now.utc - @issued_at).to_i,
            ActiveSupport::SecureRandom.base64(16)
          ].join(':')
        end
      end
    end
  end
end

require 'rack/oauth2/access_token/mac/verifier'
require 'rack/oauth2/access_token/mac/body_hash'
require 'rack/oauth2/access_token/mac/signature'
