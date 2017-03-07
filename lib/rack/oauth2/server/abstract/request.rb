module Rack
  module OAuth2
    module Server
      module Abstract
        class Request < Rack::Request
          include AttrRequired, AttrOptional
          attr_required :client_id
          attr_optional :scope

          def initialize(env)
            super
            @client_id ||= params['client_id']
            @scope = Array(params['scope'].to_s.split(' '))
          end

          def params_from_post_json
            @_coup_params = {}

            if env['RAW_POST_DATA'].to_s.length > 0 && env['CONTENT_TYPE'] == 'application/json'
              @_coup_params = ActiveSupport::JSON.decode(env['RAW_POST_DATA'])
            end
          ensure
            @_coup_params.to_h
          end

          def params
            params_from_post_json.merge!(super.to_h)
          end

          def attr_missing!
            if params['client_id'].present? && @client_id != params['client_id']
              invalid_request! 'Multiple client credentials are provided.'
            end
            super
          rescue AttrRequired::AttrMissing => e
            invalid_request! e.message, state: @state, redirect_uri: @redirect_uri
          end
        end
      end
    end
  end
end
