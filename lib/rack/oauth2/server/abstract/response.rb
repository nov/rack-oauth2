module Rack
  module OAuth2
    module Server
      module Abstract
        class Response < Rack::Response
          def initialize(request)
            super([], 200, {})
          end

          def required_params
            []
          end

          def verify_required_params!
            missing_params = []
            required_params.each do |key|
              missing_params << key unless self.send(key)
            end
            unless missing_params.blank?
              raise "Setup '#{missing_params.join('\', \'')}' first!"
            end
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