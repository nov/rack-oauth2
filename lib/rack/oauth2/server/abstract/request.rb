module Rack
  module OAuth2
    module Server
      module Abstract
        class Request < Rack::Request
          attr_accessor :client_id, :scope

          def initialize(env)
            super
            verify_required_params!
            @client_id = params['client_id']
            @scope = Array(params['scope'].to_s.split(' '))
          end

          def required_params
            [:client_id]
          end

          def verify_required_params!
            missing_params = []
            required_params.each do |key|
              missing_params << key unless params[key.to_s]
            end
            unless missing_params.blank?
              raise BadRequest.new(:invalid_request, "'#{missing_params.join('\', \'')}' required", :state => @state, :redirect_uri => @redirect_uri)
            end
          end
        end
      end
    end
  end
end