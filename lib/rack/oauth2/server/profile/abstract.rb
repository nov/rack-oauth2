module Rack
  module OAuth2
    module Server
      module Profile
        class Abstract < Rack::Auth::AbstractHandler

          private

          def unauthorized(www_authenticate = challenge)
            return [ 401,
              { 'Content-Type' => 'text/json',
                'Content-Length' => '0',
                'WWW-Authenticate' => www_authenticate.to_json },
              []
            ]
          end

          def bad_request(www_authenticate = challenge)
            return [ 400,
              { 'Content-Type' => 'text/json',
                'Content-Length' => www_authenticate.to_json },
              []
            ]
          end

        end
      end
    end
  end
end