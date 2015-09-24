require 'base64'

module Rack
  module OAuth2
    module Util
      class IndifferentAccessHash < ::Hash
        include Hashie::Extensions::IndifferentAccess
      end

      class << self
        def rfc3986_encode(text)
          URI.encode(text, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
        end

        def base64_encode(text)
          Base64.encode64(text).gsub(/\n/, '')
        end

        def compact_hash(hash)
          hash.reject do |key, value|
            Util.is_blank? value
          end
        end

        def check_presence_of(object)
          !is_blank? object
        end

        def is_blank?(object)
          object.nil? ||
          (object.respond_to? :blank? and object.blank?) ||
          (object.respond_to? :empty? and object.empty?)
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

        def to_query(hash)
          hash.map do |key, value|
            "#{CGI.escape(key.to_s)}=#{CGI.escape(value.to_s)}"
          end.sort.join '&'
        end

        def redirect_uri(base_uri, location, params)
          redirect_uri = parse_uri base_uri

          query = Util.to_query Util.compact_hash params

          case location
          when :query
            redirect_uri.query = [redirect_uri.query, query].compact.join('&')
          when :fragment
            redirect_uri.fragment = query
          end
          redirect_uri.to_s
        end

        def uri_match?(base, given)
          base = parse_uri(base)
          given = parse_uri(given)
          base.path = '/'  if Util.is_blank? base.path
          given.path = '/' if Util.is_blank? given.path
          [:scheme, :host, :port].all? do |key|
            base.send(key) == given.send(key)
          end && !!(/^#{base.path}/ =~ given.path)
        rescue
          false
        end

      end
    end
  end
end