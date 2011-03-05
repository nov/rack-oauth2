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

          def attr_missing_with_error_handling!
            if params['client_id'].present? && @client_id != params['client_id']
              invalid_request! 'Multiple client credentials are provided.'
            end
            attr_missing_without_error_handling!
          rescue AttrRequired::AttrMissing => e
            invalid_request! e.message, :state => @state, :redirect_uri => @redirect_uri
          end
          alias_method_chain :attr_missing!, :error_handling
        end
      end
    end
  end
end