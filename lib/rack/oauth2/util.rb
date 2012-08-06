require 'base64'

module Rack
  module OAuth2
    module Util
      class << self
        def rfc3986_encode(text)
          URI.encode(text, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
        end

        def base64_encode(text)
          Base64.encode64(text).gsub(/\n/, '')
        end

        def compact_hash(hash)
          hash.reject do |key, value|
            value.blank?
          end
        end

        def parse_uri(uri)
          case uri
          when URI::Generic
            uri
          when String
            URI.parse(uri)
          else
            raise "Invalid format of URI is given."
          end
        end

        def redirect_uri(base_uri, location, params)
          redirect_uri = parse_uri base_uri
          case location
          when :query
            redirect_uri.query = [redirect_uri.query, Util.compact_hash(params).to_query].compact.join('&')
          when :fragment
            redirect_uri.fragment = Util.compact_hash(params).to_query
          end
          redirect_uri.to_s
        end

        def uri_match?(base, given)
          base = parse_uri(base)
          given = parse_uri(given)
          base.path = '/' if base.path.blank?
          given.path = '/' if given.path.blank?
          [:scheme, :host, :port].all? do |key|
            base.send(key) == given.send(key)
          end && /^#{base.path}/ =~ given.path
        rescue
          false
        end

      end
    end
  end
end