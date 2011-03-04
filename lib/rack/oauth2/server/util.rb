module Rack
  module OAuth2
    module Server
      module Util
        class << self
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

          def verify_redirect_uri(registered, given)
            registered = parse_uri(registered)
            given = parse_uri(given)
            registered.path = '/' if registered.path.blank?
            given.path = '/' if given.path.blank?
            [:scheme, :host, :port].all? do |key|
              registered.send(key) == given.send(key)
            end && /^#{registered.path}/ =~ given.path
          rescue
            false
          end
        end
      end
    end
  end
end