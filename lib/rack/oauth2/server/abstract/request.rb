module Rack
  module OAuth2
    module Server
      module Abstract
        class Request < Rack::Request
          include RequiredParams
          attr_required :client_id
          attr_accessor :scope

          def initialize(env)
            super
            @client_id ||= params['client_id']
            @scope = Array(params['scope'].to_s.split(' '))
          end

          def verify_required_params_with_error_handling!
            if params['client_id'].present? && @client_id != params['client_id']
              invalid_client!("Multiple client credentials are provided.")
            end
            verify_required_params_without_error_handling!
          rescue ParameterMissing => e
            invalid_request!(e.message, :state => @state, :redirect_uri => @redirect_uri)
          end
          alias_method_chain :verify_required_params!, :error_handling

        end
      end
    end
  end
end