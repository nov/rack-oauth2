module Rack
  module OAuth2
    class Client
      class Approval
        def initialize(attributes = {})
          required_attributes.each do |key|
            self.send "#{key}=", attributes[key]
          end
          attr_missing!
        end

        def to_hash
          required_attributes.inject({}) do |hash, key|
            hash.merge! key => self.send(key)
          end
        end
      end
    end
  end
end

require 'rack/oauth2/client/approval/authorization_code'
require 'rack/oauth2/client/approval/resource_owner_credentials'
require 'rack/oauth2/client/approval/client_credentials'