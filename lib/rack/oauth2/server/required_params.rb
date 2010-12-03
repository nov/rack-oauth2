module Rack
  module OAuth2
    module Server
      module RequiredParams
        class ParameterMissing < StandardError; end

        def self.included(klass)
          class << klass

            def attr_required(*keys)
              @required_params ||= []
              @required_params += Array(keys)
              attr_accessor *keys
            end

            def required_params
              @required_params
            end

            def inherited(subclass)
              if required_params.present?
                subclass.attr_required *required_params
              end
            end

          end
        end

        def required_params
          self.class.required_params
        end

        def missing_params
          Array(required_params).select do |key|
            send(key).blank?
          end
        end

        def verify_required_params!
          raise ParameterMissing.new("'#{missing_params.join('\', \'')}' required.") if missing_params.present?
        end
      end
    end
  end
end