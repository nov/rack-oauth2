module Rack
  module OAuth2
    module Server
      module Util
        class << self
          def redirect_uri(base_uri, location, parmas)
            _params_ = parmas.reject do |key, value|
              value.blank?
            end
            redirect_uri = parse_uri base_uri
            case protocol_params_location
            when :query
              redirect_uri.query = [redirect_uri.query, _params_.to_query].compact.join('&')
            when :fragment
              redirect_uri.fragment = _params_.to_query
            end
            redirect_uri.to_s
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