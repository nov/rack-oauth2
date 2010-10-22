module Rack
  module OAuth2
    module Server
      class Error
        module Authorize

          DEFAULT_DESCRIPTION = {
            :invalid_request => "The request is missing a required parameter, includes an unsupported parameter or parameter value, or is otherwise malformed.",
            :invalid_client => "The client identifier provided is invalid.",
            :unauthorized_client => "The client is not authorized to use the requested response type.",
            :redirect_uri_mismatch => "The redirection URI provided does not match a pre-registered value.",
            :access_denied => "The end-user or authorization server denied the request.",
            :unsupported_response_type => "The requested response type is not supported by the authorization server.",
            :invalid_scope => "The requested scope is invalid, unknown, or malformed."
          }

          def error!(error, description = nil, options = {})
            description ||= DEFAULT_DESCRIPTION[error]
            raise BadRequest.new(error, description, options.merge(:state => state, :redirect_uri => redirect_uri))
          end

          def invalid_request!(description = nil, options = {})
            error!(:invalid_request, description, options)
          end

          def invalid_client!(description = nil, options = {})
            error!(:invalid_client, description, options)
          end

          def unauthorized_client!(description = nil, options = {})
            error!(:unauthorized_client, description, options)
          end

          def redirect_uri_mismatch!(description = nil, options = {})
            error!(:redirect_uri_mismatch, description, options)
          end

          def access_denied!(description = nil, options = {})
            error!(:access_denied, description, options)
          end

          def unsupported_response_type!(description = nil, options = {})
            error!(:unsupported_response_type, description, options)
          end

          def invalid_scope!(description = nil, options = {})
            error!(:invalid_scope, description, options)
          end

        end
      end
    end
  end
end