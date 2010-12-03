module Rack
  module OAuth2
    module Server
      module Abstract
        class Response < Rack::Response
          include RequiredParams

          def initialize(request)
            super([], 200, {})
          end

          def finish
            verify_required_params!
            super
          end
        end
      end
    end
  end
end