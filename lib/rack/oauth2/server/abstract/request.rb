module Rack
  module OAuth2
    module Server
      module Abstract
        class Request < Rack::Request
          attr_accessor :client_id, :scope

          def initialize(env)
            super
            missing_params = verify_required_params
            @client_id ||= params['client_id']
            @scope = Array(params['scope'].to_s.split(' '))
            missing_params << :client_id if @client_id.blank?
            unless missing_params.blank?
              invalid_request!("'#{missing_params.join('\', \'')}' required.", :state => @state, :redirect_uri => @redirect_uri)
            end
            if params['client_id'].present? && @client_id != params['client_id']
              invalid_client!("Multiple client credentials are provided.")
            end
          end

          def required_params
            []
          end

          def verify_required_params
            missing_params = []
            required_params.each do |key|
              missing_params << key unless params[key.to_s]
            end
            missing_params
          end

        end
      end
    end
  end
end