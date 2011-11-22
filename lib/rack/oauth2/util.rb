require 'base64'
require 'addressable/uri'

module Rack
  module OAuth2
    module Util
      class << self
        def rfc3986_encode(text)
          Addressable::URI.normalize_component(text, /[^#{Addressable::URI::CharacterClasses::UNRESERVED}]/)
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
          when Addressable::URI
            uri
          when URI::Generic
            Addressable::URI.parse uri
          when String
            Addressable::URI.parse(uri).tap do |parsed|
              # Fires validation
              "#{parsed}"
            end
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
          ( if "#{base.host[0].chr}" == '.'
            given.host =~ /^[a-zA-Z0-9]+\.#{Regexp.escape base.host[1...base.host.length]}$/
          else
            base.host == given.host
          end ) &&
          [:scheme, :port].all? do |key|
            base.send(key) == given.send(key)
          end && /^#{base.path}/ =~ given.path
        rescue
          false
        end
      end
    end
  end
end
