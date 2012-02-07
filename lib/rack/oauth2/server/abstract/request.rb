module Rack
  module OAuth2
    module Server
      module Abstract
        class Request < Rack::Request
          include AttrRequired, AttrOptional

          def attr_missing_with_error_handling!
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