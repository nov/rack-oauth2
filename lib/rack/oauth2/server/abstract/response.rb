module Rack
  module OAuth2
    module Server
      module Abstract
        class Response < Rack::Response
          include AttrRequired, AttrOptional

          def initialize(request)
            super([], 200, {})
          end

          def finish(skip_attr_check = false)
            attr_missing! unless skip_attr_check
            super()
          end
        end
      end
    end
  end
end