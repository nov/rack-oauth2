module Rack
  module OAuth2
    module Server
      module RequiredParams
        class ParameterMissing < StandardError; end

        def self.included(klass)
          class << klass

            def attr_required(*keys)
              @required_params = if superclass.respond_to?(:"#{type}_params")
                superclass.send(:"#{type}_params")
              else
                []
              end
              @required_params += Array(keys)
              attr_accessor *keys
            end

            def required_params
              @required_params || []
            end

          end
        end

        def missing_params
          self.class.required_params.select do |key|
            self.send(key).blank?
          end
        end

        def verify_required_params!
          raise ParameterMissing.new("'#{missing_params.join('\', \'')}' required.") if missing_params.present?
        end
      end
    end
  end
end