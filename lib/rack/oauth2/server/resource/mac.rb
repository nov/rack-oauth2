module Rack
  module OAuth2
    module Server
      class Resource
        class MAC < Resource
          def call(env)
            self.request = Request.new(env)
            super
          end

          private

          class Request < Resource::Request
            attr_reader :timestamp, :nonce, :body_hash, :signature

            def setup!
              auth_params = @auth_header.params.split(' ').inject({}) do |auth_params, pair|
                key, value = pair.scan(/^(.*)=\"(.*)\"/).flatten
                auth_params.merge!(key => value)
              end.with_indifferent_access
              @access_token = auth_params[:token]
              @timestamp = auth_params[:timestamp]
              @nonce = auth_params[:nonce]
              @body_hash = auth_params[:bodyhash]
              @signature = auth_params[:signature]
              self
            end

            def oauth2?
              @auth_header.provided? && @auth_header.scheme == :mac
            end
          end
        end
      end
    end
  end
end

require 'rack/oauth2/server/resource/mac/error'