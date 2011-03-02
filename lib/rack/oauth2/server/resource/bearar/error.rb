module Rack
  module OAuth2
    module Server
      module Resource
        class Bearer::Error

          DEFAULT_DESCRIPTION = {
            :invalid_request => "The request is missing a required parameter, includes an unsupported parameter or parameter value, repeats the same parameter, uses more than one method for including an access token, or is otherwise malformed.",
            :invalid_token => "The access token provided is invalid.",
            :expired_token => "The access token provided has expired.",
            :insufficient_scope => "The request requires higher privileges than provided by the access token."
          }

          def error!(error, description = nil, options = {})
            description ||= DEFAULT_DESCRIPTION[error]
            exception = case error
            when :invalid_token, :expired_token
              Unauthorized
            when :insufficient_scope
              Forbidden
            when :invalid_request
              BadRequest
            else
              raise Error.new(options[:status] || 400, error, description, options)
            end
            raise exception.new(error, description, options)
          end

          def invalid_request!(description = nil, options = {})
            error!(:invalid_request, description, options)
          end

          def invalid_token!(description = nil, options = {})
            error!(:invalid_token, description, options)
          end

          def expired_token!(description = nil, options = {})
            error!(:expired_token, description, options)
          end

          def insufficient_scope!(description = nil, options = {})
            error!(:insufficient_scope, description, options)
          end

        end
      end
    end
  end
end