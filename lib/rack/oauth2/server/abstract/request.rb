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
            parse_json

            @client_id ||= params['client_id']
            @scope = Array(params['scope'].to_s.split(' '))
          end

          def parse_json
            result = {}

            if body.size > 0 && env['CONTENT_TYPE'] == 'application/json'
              body.rewind
              result = ActiveSupport::JSON.decode(body.read)
            end

          ensure
            @_coup_params = result
          end

          def params
            @_coup_params.merge!(super)
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
