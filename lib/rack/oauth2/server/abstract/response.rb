module Rack
  module OAuth2
    module Server
      module Abstract
        class Response < Rack::Response
          def initialize(request)
            super([], 200, {})
          end
        end
      end
    end
  end
end