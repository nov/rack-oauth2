module Rack
  module OAuth2
    module Server
      class Authorize
        class CodeAndToken < Abstract::Handler

          def call(env)
            @request  = Request.new(env)
            @response = Response.new(request)
            super
          end

          class Request < Authorize::Request
            def initialize(env)
              super
              @response_type = :code_and_token
              verify_required_params!
            end
          end

          class Response < Authorize::Response
            attr_required :code, :access_token
            attr_accessor :expires_in, :scope

            def finish
              if approved?
                # append query params
                query_params = {
                  :code => code,
                  :state => state
                }.delete_if do |key, value|
                  value.blank?
                end
                redirect_uri.query = if redirect_uri.query
                  [redirect_uri.query, query_params.to_query].join('&')
                else
                  query_params.to_query
                end
                # append fragment params
                fragment_params = {
                  :access_token => access_token,
                  :expires_in => expires_in,
                  :scope => Array(scope).join(' ')
                }.delete_if do |key, value|
                  value.blank?
                end
                redirect_uri.fragment = if redirect_uri.fragment
                  [redirect_uri.fragment, fragment_params.to_query].join('&')
                else
                  fragment_params.to_query
                end
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