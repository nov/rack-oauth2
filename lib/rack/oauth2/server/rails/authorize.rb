module Rack
  module OAuth2
    module Server
      module Rails
        class Authorize < Server::Authorize
          def initialize(app)
            super()
            @app = app
          end

          def call(env)
            prepare_oauth_env env
            @app.call env
          end

          private

          def prepare_oauth_env(env)
            request = Server::Authorize::Request.new(env)
            env[REQUEST] = request
            response = response_type_for(request).new.call(env)
            response.extend ResponseExt
            env[RESPONSE] = response
          rescue Rack::OAuth2::Server::Abstract::Error => e
            env[ERROR] = e
          end

          module ResponseExt
            include Rails::ResponseExt

            def approve!
              super
              finish
            end
          end
        end
      end
    end
  end
end
