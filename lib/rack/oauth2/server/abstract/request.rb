module Rack
  module OAuth2
    module Server
      module Abstract
        class Request < Rack::Request
          include AttrRequired, AttrOptional
          attr_required :client_id
          attr_optional :scope

          # Constants
          #
          CONTENT_TYPE = 'CONTENT_TYPE'.freeze
          POST_BODY = 'rack.input'.freeze
          FORM_INPUT = 'rack.request.form_input'.freeze
          FORM_HASH = 'rack.request.form_hash'.freeze

          # Supported Content-Types
          #
          APPLICATION_JSON = 'application/json'.freeze

          def initialize(env)
            super
            handle_json_payload_if_needed
            @client_id ||= params['client_id']
            @scope = Array(params['scope'].to_s.split(' '))
          end

          def handle_json_payload_if_needed
            if Rack::Request.new(env).media_type == APPLICATION_JSON && (body = env[POST_BODY].read).length != 0
              env[POST_BODY].rewind
            elsif env['RAW_POST_DATA'].to_s.length > 0 && env['CONTENT_TYPE'] == 'application/json'
              body = env['RAW_POST_DATA'] if env['RAW_POST_DATA'].length > 0
            end

            env.update(
              FORM_HASH => ActiveSupport::JSON.decode(body),
              FORM_INPUT => env[POST_BODY]
            ) if body
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
