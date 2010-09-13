module Rack
  module OAuth2
    module Server
      class Authorization
        class UserAgent < Abstract::Handler

          def call(env)
            @request  = Request.new(env)
            @response = Response.new(request)
            super
          end

          class Request < Authorization::Request
            attr_reader :client_id, :redirect_uri, :scope, :state

            def initialize(env)
              super
              @response_type = 'token'
              @client_id     = params['client_id']
              @redirect_uri  = URI.parse(params['redirect_uri']) rescue nil
              @redirect_uri  = nil unless @redirect_uri.scheme
              @scope         = Array(params['scope'].to_s.split(' '))
              @state         = params['state']
            end

            def requred_params
              [:response_type, :client_id, :redirect_uri]
            end
          end

          class Response < Authorization::Response
            attr_accessor :access_token, :expires_in, :scope

            def finish
              if approved?
                fragment = Array(redirect_uri.fragment)
                fragment << "access_token=#{URI.encode access_token}"
                fragment << "expires_in=#{URI.encode expires_in.to_s}" if expires_in
                fragment << "scope=#{URI.encode Array(scope).join(' ')}" if scope
                query_params << "state=#{URI.encode state}" if state
                redirect_uri.fragment = fragment.join('&')
                redirect redirect_uri.to_s
              end
              super
            end
          end

        end
      end
    end
  end
end