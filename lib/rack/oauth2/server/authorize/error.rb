module Rack
  module OAuth2
    module Server
      class Authorize
        class BadRequest < Abstract::BadRequest
          attr_accessor :redirect_uri, :state, :protocol_params_location

          def protocol_params
            super.merge(:state => state)
          end

          def finish
            if redirect_uri.present? && protocol_params_location.present?
              super do |response|
                response.redirect Util.redirect_uri(redirect_uri, protocol_params_location, protocol_params)
              end
            else
              raise self
            end
          end
        end

        module ErrorMethods
          DEFAULT_DESCRIPTION = {
            :invalid_request => "The request is missing a required parameter, includes an unsupported parameter or parameter value, or is otherwise malformed.",
            :unauthorized_client => "The client is not authorized to use the requested response type.",
            :access_denied => "The end-user or authorization server denied the request.",
            :unsupported_response_type => "The requested response type is not supported by the authorization server.",
            :invalid_scope => "The requested scope is invalid, unknown, or malformed."
          }

          def bad_request!(error = :bad_request, description = nil, options = {})
            description ||= DEFAULT_DESCRIPTION[error]
            exception = BadRequest.new error, description, options
            exception.protocol_params_location = case response_type
            when :code
              :query
            when :token
              :fragment
            end
            exception.state = state
            exception.redirect_uri = redirect_uri if DEFAULT_DESCRIPTION.keys.include?(error)
            raise exception
          end

          def invalid_request!(description = nil, options = {})
            bad_request! :invalid_request, description, options
          end

          def access_denied!(description = nil, options = {})
            bad_request! :access_denied, description, options
          end

          def unsupported_response_type!(description = nil, options = {})
            bad_request! :unsupported_response_type, description, options
          end

          def invalid_scope!(description = nil, options = {})
            bad_request! :invalid_scope, description, options
          end
        end

        Request.send :include, ErrorMethods
      end
    end
  end
end