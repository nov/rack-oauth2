module Rack
  module OAuth2
    module Server
      module Token
        class Error

          DEFAULT_DESCRIPTION = {
            :invalid_request => "The request is missing a required parameter, includes an unsupported parameter or parameter value, repeats a parameter, includes multiple credentials, utilizes more than one mechanism for authenticating the client, or is otherwise malformed.",
            :invalid_client => "The client identifier provided is invalid, the client failed to authenticate, the client did not include its credentials, provided multiple client credentials, or used unsupported credentials type.",
            :unauthorized_client => "The authenticated client is not authorized to use the access grant type provided.",
            :invalid_grant => "The provided access grant is invalid, expired, or revoked (e.g. invalid assertion, expired authorization token, bad end-user password credentials, or mismatching authorization code and redirection URI).",
            :unsupported_grant_type => "The access grant included - its type or another attribute - is not supported by the authorization server.",
            :unsupported_response_type => "The requested response type is not supported by the authorization server.",
            :invalid_scope => "The requested scope is invalid, unknown, malformed, or exceeds the previously granted scope."
          }

          def error!(error, description = nil, options = {})
            description ||= DEFAULT_DESCRIPTION[error]
            exception = if options.delete(:unauthorized)
              Unauthorized
            else
              BadRequest
            end
            raise exception.new(error, description, options)
          end

          def invalid_request!(description = nil, options = {})
            error!(:invalid_request, description, options)
          end

          def invalid_client!(description = nil, options = {})
            error!(:invalid_client, description, options.merge(:unauthorized => via_authorization_header))
          end

          def unauthorized_client!(description = nil, options = {})
            error!(:unauthorized_client, description, options)
          end

          def invalid_grant!(description = nil, options = {})
            error!(:invalid_grant, description, options)
          end

          def unsupported_grant_type!(description = nil, options = {})
            error!(:unsupported_grant_type, description, options)
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