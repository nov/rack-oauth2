require 'rack/auth/abstract/handler'

module Rack
  module OAuth2
    module Server
      module Abstract
        class Handler < Rack::Auth::AbstractHandler
          attr_accessor :request, :response

          def initialize(realm = '', &authenticator)
            super(nil, realm, &authenticator)
          end

          def call(env)
            @authenticator.call(@request, @response) if @authenticator
            env['rack.oauth2.request'] = @request
            env['rack.oauth2.response'] = @response
            @response
          end
        end
      end
    end
  end
end