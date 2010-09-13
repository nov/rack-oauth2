module Rack
  module OAuth2
    module Server
      module Abstract
        class Request < Rack::Request
          def initialize(env)
            super(env)
            verify_required_params!
          end

          def required_params
            raise "Implement verify_required_params! in #{self.class}"
          end

          def verify_required_params!
            missing_params = []
            required_params.each do |key|
              missing_params << key unless params[key.to_s]
            end
            unless missing_params.empty?
              raise BadRequest.new(:invalid_request, "'#{missing_params.join('\', \'')}' required")
            end
          end
        end
      end
    end
  end
end