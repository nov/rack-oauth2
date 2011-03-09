module Rack
  module OAuth2
    class Client
      class Grant
        include AttrRequired, AttrOptional

        def initialize(attributes = {})
          required_attributes.each do |key|
            self.send "#{key}=", attributes[key]
          end
          attr_missing!
        end

        def to_hash
          hash = required_attributes.inject({}) do |hash, key|
            hash.merge! key => self.send(key)
          end
          hash[:grant_type] = self.class.name.downcase.to_sym
        end
      end
    end
  end
end

require 'rack/oauth2/client/grant/authorization_code'
require 'rack/oauth2/client/grant/password'
require 'rack/oauth2/client/grant/client_credentials'