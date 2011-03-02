module Rack
  module OAuth2
    module Server
      module Token
        class BadRequest < Abstract::BadRequest
          def finish
            super do |response|
              response.header['Content-Type'] = 'application/json'
              response.write _protocol_params_.to_json
            end
          end
        end

        class Unauthorized < Abstract::Unauthorized
          def finish
            super do |response|
              response.header['Content-Type'] = 'application/json'
              response.header['WWW-Authenticate'] = 'Basic realm="OAuth2 Token Endpoint"'
              response.write _protocol_params_.to_json
            end
          end
        end

        module ErrorMethods
          DEFAULT_DESCRIPTION = {
            :invalid_request => "The request is missing a required parameter, includes an unsupported parameter or parameter value, repeats a parameter, includes multiple credentials, utilizes more than one mechanism for authenticating the client, or is otherwise malformed.",
            :invalid_client => "The client identifier provided is invalid, the client failed to authenticate, the client did not include its credentials, provided multiple client credentials, or used unsupported credentials type.",
            :invalid_grant => "The provided access grant is invalid, expired, or revoked (e.g. invalid assertion, expired authorization token, bad end-user password credentials, or mismatching authorization code and redirection URI).",
            :unauthorized_client => "The authenticated client is not authorized to use the access grant type provided.",
            :unsupported_grant_type => "The access grant included - its type or another attribute - is not supported by the authorization server.",
            :invalid_scope => "The requested scope is invalid, unknown, malformed, or exceeds the previously granted scope."
          }

          def bad_request!(error, description = nil, options = {})
            description ||= DEFAULT_DESCRIPTION[error]
            raise BadRequest.new(error, description, options)
          end

          def unauthorized!(error, description = nil, options = {})
            description ||= DEFAULT_DESCRIPTION[error]
            raise Unauthorized.new(error, description, options)
          end

          def invalid_request!(description = nil, options = {})
            bad_request!(:invalid_request, description, options)
          end

          def invalid_client!(description = nil, options = {})
            unauthorized!(:invalid_client, description, options)
          end

          def invalid_grant!(description = nil, options = {})
            bad_request!(:invalid_grant, description, options)
          end

          def unauthorized_client!(description = nil, options = {})
            bad_request!(:unauthorized_client, description, options)
          end

          def unsupported_grant_type!(description = nil, options = {})
            bad_request!(:unsupported_grant_type, description, options)
          end

          def invalid_scope!(description = nil, options = {})
            bad_request!(:invalid_scope, description, options)
          end
        end

        Request.send :include, ErrorMethods
      end
    end
  end
end